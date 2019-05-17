dockerq:images:_main() {
    dockerq:main:parse_list_args "$@"

    if [[ "${DOCKERQ_PRINTNAME:-}" = true ]]; then
        dockerq:run images --format '{{.Repository}}:{{.Tag}}'

    elif [[ "${DOCKERQ_PRINTID:-}" = true ]]; then
        dockerq:run images --format '{{.ID}}'

    elif [[ -n "${DOCKERQ_FORMATSTRING:-}" ]]; then
        dockerq:run images --format "${DOCKERQ_FORMATSTRING:-}" | dockerq:common:column

    else
        dockerq:run images
    fi
}
