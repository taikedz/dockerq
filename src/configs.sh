
dctl:config:_list_stored_strings() {
    out:info "These are the configured filters"

    local available_files=(:)
    local k f keys

    for f in "${DCTL_ASSET_CONFIGS[@]}"; do
        [[ ! -f "$f" ]] || available_files+=("$f")
    done

    debug:print "Files: ${available_files[*]:1}"

    if [[ "${#available_files[@]}" -lt 2 ]]; then
        out:fail "No config file found."
    fi

    # Get keys
    keys=($(grep -hPo '^(.+?)(?=\=)' "${available_files[@]:1}"|sort|uniq) )

    for k in "${keys[@]}"; do
        echo "$k --> $(config:read DCTL_JSON_FILTERS "$k")"
    done
}

dctl:config:read() {
    local value
    config:read "$@" || out:fail "Could not read from config | $2"
}

dctl:config:_set_asset_configs() {
    local cfname="dockerctl-queries.conf"
    local cfpath="dockerctl/$cfname"

    DCTL_ASSET_CONFIGS=(
        "./$cfname"
        "$HOME/.config/$cfpath"
        "/etc/$cfpath"
    )

    config:declare DCTL_JSON_FILTERS "${DCTL_ASSET_CONFIGS[@]}"
}
dctl:config:_set_asset_configs
