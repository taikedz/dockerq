dctl:volumes:_main() {
    dctl:main:parse_list_args "$@"

    if [[ "${DCTL_PRINTNAME:-}" = true ]]; then
        dctl:run volume ls --format '{{.Name}}'

    elif [[ "${DCTL_PRINTID:-}" = true ]]; then
        dctl:run volume ls --format '{{.Name}}'

    elif [[ -n "${DCTL_FORMATSTRING:-}" ]]; then
        dctl:run volume ls --format "${DCTL_FORMATSTRING:-}" | dctl:common:column

    else
        dctl:run volume ls
    fi
}

