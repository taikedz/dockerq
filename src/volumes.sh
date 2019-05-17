dockerq:volumes:_main() {
    dockerq:main:parse_list_args "$@"

    if [[ "${DOCKERQ_PRINTNAME:-}" = true ]]; then
        dockerq:run volume ls --format '{{.Name}}'

    elif [[ "${DOCKERQ_PRINTID:-}" = true ]]; then
        dockerq:run volume ls --format '{{.Name}}'

    elif [[ -n "${DOCKERQ_FORMATSTRING:-}" ]]; then
        dockerq:run volume ls --format "${DOCKERQ_FORMATSTRING:-}" | dockerq:common:column

    else
        dockerq:run volume ls
    fi
}

