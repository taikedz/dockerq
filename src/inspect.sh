### dockerctl inspect ASSETNAME FILTERNAME [OPTIONS] Usage:help
#
# OPTIONS
# -------
#
# -t, --type
#   Specify an asset type for inspection; useful if two asset types share a name
#
#
#
# ASSETNAME
# ---------
#
# If the `-a` or `--all` global option was passed, `ASSETNAME` serves as a filter to apply to all asset names of a given type.
#
# The special name `--list` will list all available saved filters.
#
#
# FILTERNAME
# ----------
#
# Use a saved filter name. You can add these to a dockerctl-queries.conf file in your local directory, or in $HOME/.config/dockerctl/ or /etc/dockerctl/
#
# Example
# -------
#
# Given this entry in the config file
#
#   ipf=.[0].NetworkSettings.Networks[].IPAddress
#
# You can call like this
#
#   dockerctl inspect mycontainer ipf
#
# To get the IP of the specified container, or
#
#   dockerctl inspect somename ipf -t container
#
# To apply `somename` as a matching filter to all `container` names to run the inspect query against
#
###/doc

$%function dctl:inspect:_main(assetname filtername) {
    if [[ "$assetname" = '--list' ]]; then
        dctl:config:_list_stored_strings
        exit
    fi

    local filterdefs=(
        s:assettype:-t,--type
        b:DEBUG_mode:--debug
        b:DCTL_ALL:-a,--all
    )
    local assettype jsonstring

    args:parse filterdefs - "$@"

    dctl:inspect:_load_json_string jsonstring "$filtername"

    # Extrapolate asset type and set the flag array
    if [[ -n "${assettype:-}" ]]; then
        dctl:inspect:_extrapolate_type assettype
        assettype_a=(: --type="$assettype")
    else
        assettype_a=(:)
    fi

    # Use extrapolated asset type and list assets
    if [[ "${DCTL_ALL:-}" = true ]] && [[ -n "${assettype:-}" ]]; then
        all_assets=($(dctl:${assettype}s:_main -n | grep "$assetname"))
    else
        all_assets=("$assetname")
    fi

    # =====
    for one_asset in "${all_assets[@]}"; do
        dctl:run inspect "${assettype_a[@]:1}" "$one_asset" | jq "$jsonstring"
    done
}

$%function dctl:inspect:_load_json_string(*p_return filtername) {
    p_return="$(dctl:config:read DCTL_JSON_FILTERS "$filtername")"
    debug:print "Loaded json string: ${CBTEA}$p_return"
}

$%function dctl:inspect:_extrapolate_type(*p_assettype) {
    case "$p_assettype" in
    v|volume) p_assettype=volume ;;
    i|image) p_assettype=image ;;
    c|container) p_assettype=container ;;
    n|network) p_assettype=network ;;
    *) out:fail "Unknown asset type '$p_assettype'" ;;
    esac
}
