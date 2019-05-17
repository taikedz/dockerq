dctl:images:_main() {
    dctl:main:parse_list_args "$@"

    if [[ "${DCTL_PRINTNAME:-}" = true ]]; then
        dctl:run images --format '{{.Repository}}:{{.Tag}}'

    elif [[ "${DCTL_PRINTID:-}" = true ]]; then
        dctl:run images --format '{{.ID}}'

    elif [[ -n "${DCTL_FORMATSTRING:-}" ]]; then
        dctl:run images --format "${DCTL_FORMATSTRING:-}" | dctl:common:column

    else
        dctl:run images
    fi
}
