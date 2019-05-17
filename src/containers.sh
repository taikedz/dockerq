dctl:containers:_main() {
    dctl:main:parse_list_args "$@"

    if [[ "${DCTL_PRINTNAME:-}" = true ]]; then
        dctl:run ps "${DCTL_ALL[@]:1}" --format '{{.Names}}'

    elif [[ "${DCTL_PRINTID:-}" = true ]]; then
        dctl:run ps "${DCTL_ALL[@]:1}" --format '{{.ID}}'

    elif [[ -n "${DCTL_FORMATSTRING:-}" ]]; then
        dctl:run ps "${DCTL_ALL[@]:1}" --format "${DCTL_FORMATSTRING:-}" | dctl:common:column

    else
        dctl:run ps "${DCTL_ALL[@]:1}"
    fi
}
