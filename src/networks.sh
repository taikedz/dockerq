dockerq:networks:_main() {
    dockerq:main:parse_list_args "$@"

    if [[ "${DOCKERQ_PRINTNAME:-}" = true ]]; then
        dockerq:run network ls --format '{{.Name}}'

    elif [[ "${DOCKERQ_PRINTID:-}" = true ]]; then
        dockerq:run network ls --format '{{.ID}}'

    elif [[ -n "${DOCKERQ_FORMATSTRING:-}" ]]; then
        dockerq:run network ls --format "${DOCKERQ_FORMATSTRING:-}" | dockerq:common:column

    else
        dockerq:run network ls
    fi
}

