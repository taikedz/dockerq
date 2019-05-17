dockerq:containers:_main() {
    dockerq:main:parse_list_args "$@"

    if [[ "${DOCKERQ_PRINTNAME:-}" = true ]]; then
        dockerq:run ps "${DOCKERQ_ALL[@]:1}" --format '{{.Names}}'

    elif [[ "${DOCKERQ_PRINTID:-}" = true ]]; then
        dockerq:run ps "${DOCKERQ_ALL[@]:1}" --format '{{.ID}}'

    elif [[ -n "${DOCKERQ_FORMATSTRING:-}" ]]; then
        dockerq:run ps "${DOCKERQ_ALL[@]:1}" --format "${DOCKERQ_FORMATSTRING:-}" | dockerq:common:column

    else
        dockerq:run ps "${DOCKERQ_ALL[@]:1}"
    fi
}
