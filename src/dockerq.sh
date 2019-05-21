#!/usr/bin/env bbrun

#%include help-main.sh

#%include std/safe.sh

#%include std/autohelp.sh
#%include std/out.sh
#%include std/args.sh
#%include std/debug.sh
#%include std/config.sh

#%include common.sh
#%include configs.sh

#%include images.sh
#%include containers.sh
#%include volumes.sh
#%include networks.sh

#%include clean.sh
#%include inspect.sh

$%function dockerq:subcommand(subcommand) {
    case "$subcommand" in
    i|images)
        dockerq:images:_main "$@"
        ;;
    v|volumes)
        dockerq:volumes:_main "$@"
        ;;
    c|containers)
        dockerq:containers:_main "$@"
        ;;
    n|networks)
        dockerq:networks:_main "$@"
        ;;
    ins|inspect)
        dockerq:inspect:_main "$@"
        ;;
    clean)
        dockerq:clean:_main "$@"
        ;;
    *)
        out:fail "Unknown command: '$subcommand'"
        ;;
    esac
}

dockerq:main() {
    autohelp:check-or-null "$@"

    dockerq:subcommand "$@"
}

dockerq:main "$@"
