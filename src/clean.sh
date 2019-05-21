### dockerq clean MODE Usage:dockerq-clean
#
# Clean up docker.
#
# Only one MODE exists currently:
#
# none
#   Clean out images that have "none" names
#   Also removes any containers dependent on such images
#
#   Tool for cleaning up a development environment after many intermediary builds
#
###/doc

# TODO - only cleanup for images whose containers are not running

dockerq:clean:noneimages() {
    docker images --format '{{.ID}} {{.Repository}}/{{.Tag}}'|grep '<none>/<none>'|while read id name; do
        echo $id
    done
}

dockerq:clean:nonecontainers() {
    local images="$(dockerq:clean:noneimages|xargs echo|sed -r 's/ /|/g')";

    docker ps -a --format '{{.ID}} {{.Image}}'|grep -E "$images"|while read cid imid; do
        echo $cid
    done
}

dockerq:clean:none() {
	dockerq:clean:nonecontainers | xargs docker rm
	dockerq:clean:noneimages | xargs docker rmi
}

$%function dockerq:clean:_main(action) {
	case "$action" in
    none)
        dockerq:clean:none
        ;;
    *)
        autohelp:print dockerq-clean
        out:fail "Unknown clean method '$action'"
        ;;
    esac
}
