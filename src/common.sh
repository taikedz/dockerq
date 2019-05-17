dctl:run() {
    # Use a docker command, either running it or printing it
    local dockerstring="$(args:quote docker "$@")"

    debug:print "$dockerstring"

    if [[ "${DCTL_NOOP:-}" = true ]]; then
        out:info "$dockerstring"
    else
        docker "$@"
    fi
}

dctl:main:parse_list_args() {
    local argdefs=(
        b:DCTL_PRINTNAME:-n,--name
        b:DCTL_PRINTID:-i,--id
        s:DCTL_FORMATNAME:-f,--format
        b:DCTL_ALL:-a,--all
        b:DEBUG_mode:--debug
    )

    local res

    args:parse argdefs - "$@"

    dctl:common:only_one DCTL_PRINTNAME DCTL_PRINTID DCTL_FORMATNAME || res="$?"

    if [[ "$res" = 2 ]] ; then
        out:fail "Conflicting flags --name, --id or --format specified simultaneously. Please only use one."
    fi

    if [[ -n "${DCTL_FORMATNAME:-}" ]]; then
        debug:print "Format name supplied: $DCTL_FORMATNAME"
        DCTL_FORMATSTRING="$(dctl:config:read DCTL_JSON_FILTERS "$DCTL_FORMATNAME")"
        debug:print "--> $DCTL_FORMATSTRING"
    fi

    if [[ "${DCTL_ALL:-}" = true ]]; then
        DCTL_ALL=(: -a)
    else
        DCTL_ALL=(:)
    fi
}

dctl:common:column() {
    column -t -s $'\t'
}

dctl:common:only_one() {
    local name

    local res_found_one=0
    local res_not_set=1
    local res_is_duplicate=2
    local matched_one=$res_not_set

    for name in "$@"; do
        res=0
        (
            declare -n value="$name"

            if [[ -n "${value:-}" ]]; then
                debug:print "$res_found_one : found $name=$value"
                exit $res_found_one
            fi
            debug:print "$res_not_set : found ${name:-}=${value:-}"
            exit $res_not_set
        ) || res="$?"

        case "$res" in
        $res_found_one)
            if [[ "$matched_one" = $res_found_one ]]; then
                debug:print "$res_is_duplicate : Found a duplicate"
                return $res_is_duplicate
            fi
            debug:print "$res_found_one : found ${name:-} , registering"
            matched_one=$res_found_one
            ;;

        $res_not_set)
            true ;; # noop

        esac
    done

    return $matched_one # Either $res_not_set or $res_is_set
}
