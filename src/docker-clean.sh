#%include std/askuser.sh
#%include std/out.sh
#%include std/runmain.sh

dockerq:noneimages() {
    docker images --format '{{.ID}} {{.Repository}}/{{.Tag}}'|grep '<none>/<none>'|while read id name; do
        echo $id
        out:warn "Removing image $id"
    done
}

dockerq:nonecontainers() {
    local images="$(dockerq:noneimages|xargs echo|sed -r 's/ /|/g')";

    docker ps -a --format '{{.ID}} {{.Image}} {{.Names}}'|grep -E "$images"|while read cid imid cname; do
        echo $cid
        out:warn "$cname"
    done
}

$%function dockerq:dorm(extractor) {
    local ids="$("$extractor" | xargs echo)"

    if [[ -n "$ids" ]]; then
        askuser:confirm "Remove these items?" || out:fail "Abort"
        (set -x
        "$@" $ids
        )
    else
        echo "${extractor/dockerq:none/}: Nothing to remove"
    fi
}

dockerq:clean() {
    dockerq:dorm dockerq:nonecontainers docker rm
    dockerq:dorm dockerq:noneimages     docker rmi
}

runmain docker-clean.sh dockerq:clean "$@"
