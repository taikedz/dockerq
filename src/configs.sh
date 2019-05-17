
dockerq:config:_list_stored_strings() {
    out:info "These are the configured filters"

    local available_files=(:)
    local k f keys

    for f in "${DOCKERQ_ASSET_CONFIGS[@]}"; do
        [[ ! -f "$f" ]] || available_files+=("$f")
    done

    debug:print "Files: ${available_files[*]:1}"

    if [[ "${#available_files[@]}" -lt 2 ]]; then
        out:fail "No config file found."
    fi

    # Get keys
    keys=($(grep -hPo '^(.+?)(?=\=)' "${available_files[@]:1}"|sort|uniq) )

    for k in "${keys[@]}"; do
        echo "$k --> $(config:read DOCKERQ_JSON_FILTERS "$k")"
    done
}

dockerq:config:read() {
    local value
    config:read "$@" || out:fail "Could not read from config | $2"
}

dockerq:config:_set_asset_configs() {
    local cfname="dockerq-queries.conf"
    local cfpath="dockerq/$cfname"

    DOCKERQ_ASSET_CONFIGS=(
        "./$cfname"
        "$HOME/.config/$cfpath"
        "/etc/$cfpath"
    )

    config:declare DOCKERQ_JSON_FILTERS "${DOCKERQ_ASSET_CONFIGS[@]}"
}
dockerq:config:_set_asset_configs
