dctl:networks:_main() {
    dctl:main:parse_list_args "$@"

    if [[ "${DCTL_PRINTNAME:-}" = true ]]; then
        dctl:run network ls --format '{{.Name}}'

    elif [[ "${DCTL_PRINTID:-}" = true ]]; then
        dctl:run network ls --format '{{.ID}}'

    elif [[ -n "${DCTL_FORMATSTRING:-}" ]]; then
        dctl:run network ls --format "${DCTL_FORMATSTRING:-}" | dctl:common:column

    else
        dctl:run network ls
    fi
}

