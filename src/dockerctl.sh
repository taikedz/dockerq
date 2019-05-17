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

#%include inspect.sh

$%function dctl:subcommand(subcommand) {
    case "$subcommand" in
    i|images)
        dctl:images:_main "$@"
        ;;
    v|volumes)
        dctl:volumes:_main "$@"
        ;;
    c|containers)
        dctl:containers:_main "$@"
        ;;
    n|networks)
        dctl:networks:_main "$@"
        ;;
    inspect)
        dctl:inspect:_main "$@"
        ;;
    *)
        out:fail "Unknown command: '$subcommand'"
        ;;
    esac
}

dctl:main() {
    autohelp:check-or-null "$@"

    dctl:subcommand "$@"
}

dctl:main "$@"
