
##bash-libs: syntax-extensions.sh @ 0400607e (2.1.17)

### Syntax Extensions Usage:syntax
#
# Syntax extensions for bash-builder.
#
# You will need to import this library if you use Bash Builder's extended syntax macros.
#
# You should not however use the functions directly, but the extended syntax instead.
#
##/doc

### syntax-extensions:use FUNCNAME ARGNAMES ... Usage:syntax
#
# Consume arguments into named global variables.
#
# If not enough argument values are found, the first named variable that failed to be assigned is printed as error
#
# ARGNAMES prefixed with '?' do not trigger an error
#
# Example:
#
#   #%include std/out.sh
#   #%include std/syntax-extensions.sh
#
#   get_parameters() {
#       . <(syntax-extensions:use get_parameters INFILE OUTFILE ?comment -- "$@")
#
#       [[ -f "$INFILE" ]]  || out:fail "Input file '$INFILE' does not exist"
#       [[ -f "$OUTFILE" ]] || out:fail "Output file '$OUTFILE' does not exist"
#
#       [[ -z "$comment" ]] || echo "Note: $comment"
#   }
#
#   main() {
#       get_parameters "$@"
#
#       echo "$INFILE will be converted to $OUTFILE"
#   }
#
#   main "$@"
#
###/doc
syntax-extensions:use() {
    local argname arglist undef_f dec_scope argidx argone failmsg pos_ok
    
    dec_scope=""
    [[ "${SYNTAXLIB_scope:-}" = local ]] || dec_scope=g
    arglist=(:)
    argone=\"\${1:-}\"
    pos_ok=true
    
    for argname in "$@"; do
        [[ "$argname" != -- ]] || break
        [[ "$argname" =~ ^(\?|\*)?[0-9a-zA-Z_]+$ ]] || out:fail "Internal: Not a valid argument name '$argname'"

        arglist+=("$argname")
    done

    argidx=1
    while [[ "$argidx" -lt "${#arglist[@]}" ]]; do
        argname="${arglist[$argidx]}"
        failmsg="\"Internal: could not get '$argname' in function arguments\""
        posfailmsg="\"Internal: positional argument '$argname' encountered after optional argument(s)\""

        if [[ "$argname" =~ ^\? ]]; then
            echo "$SYNTAXLIB_scope ${argname:1}"
            echo "${argname:1}=$argone; shift || :"
            pos_ok=false

        elif [[ "$argname" =~ ^\* ]]; then
            if [[ "$pos_ok" = true ]]; then
                echo "[[ '${argname:1}' != \"$argone\" ]] || out:fail \"Internal: Local name [${argname:1}] is the same is the name it tries to reference. Rename [$argname] (suggestion: [*p_${argname:1}])\""
                echo "declare -n${dec_scope} ${argname:1}=$argone; shift || out:fail $failmsg"
            else
                echo "out:fail $posfailmsg"
            fi

        else
            if [[ "$pos_ok" = true ]]; then
                echo "$SYNTAXLIB_scope ${argname}"
                echo "${argname}=$argone; shift || out:fail $failmsg"
            else
                echo "out:fail $posfailmsg"
            fi
        fi

        argidx=$((argidx + 1))
    done
}


### syntax-extensions:use:local FUNCNAME ARGNAMES ... Usage:syntax
# 
# Enables syntax macro: function signatures
#   e.g. $%function func(var1 var2) { ... }
#
# Build with bbuild to leverage this function's use:
#
#   #%include out.sh
#   #%include syntax-extensions.sh
#
#   $%function person(name email) {
#       echo "$name <$email>"
#
#       # $1 and $2 have been consumed into $name and $email
#       # The rest remains available in $* :
#       
#       echo "Additional notes: $*"
#   }
#
#   person "Jo Smith" "jsmith@example.com" Some details
#
###/doc
syntax-extensions:use:local() {
    SYNTAXLIB_scope=local syntax-extensions:use "$@"
}

args:use:local() {
    syntax-extensions:use:local "$@"
}
##bash-libs: tty.sh @ 0400607e (2.1.17)

### tty.sh Usage:bbuild
# Get information on the current terminal session.
###/doc

### tty:is_ssh Usage:bbuild
# Determine whether the TTY is an SSH session.
#
# WARNING: this only works for an SSH connection still in the "landing" account.
# If the user is switched via 'su' or 'sudo', the environment is lost and the variables used to determine this are blank - by default, indicating being not in an SSH session.
###/doc
tty:is_ssh() {
    [[ -n "${SSH_TTY:-}" ]] || [[ -n "${SSH_CLIENT:-}" ]] || [[ "${SSH_CONNECTION:-}" ]]
}

### tty:is_pipe Usage:bbuild
# Determine if we are running in a pipe.
###/doc
tty:is_pipe() {
    [[ ! -t 1 ]]
}

### tty:is_multiplexer Usage:bbuild
# Determine if we are in a terminal multiplexer (detects 'screen' and 'tmux')
###/doc
tty:is_multiplexer() {
    [[ -n "${TMUX:-}" ]] || [[ "${TERM:-}" = screen ]]
}

##bash-libs: colours.sh @ 0400607e (2.1.17)

### Colours for terminal Usage:bbuild
# A series of shorthand colour flags for use in outputs, and functions to set your own flags.
#
# Not all terminals support all colours or modifiers.
#
# Example:
# 	
# 	echo "${CRED}Some red text ${CBBLU} some blue text. $CDEF Some text in the terminal's default colour"
#
# Preconfigured colours available:
#
# CRED, CBRED, HLRED -- red, bright red, highlight red
# CGRN, CBGRN, HLGRN -- green, bright green, highlight green
# CYEL, CBYEL, HLYEL -- yellow, bright yellow, highlight yellow
# CBLU, CBBLU, HLBLU -- blue, bright blue, highlight blue
# CPUR, CBPUR, HLPUR -- purple, bright purple, highlight purple
# CTEA, CBTEA, HLTEA -- teal, bright teal, highlight teal
# CBLA, CBBLA, HLBLA -- black, "bright" black, highlight black
# CWHI, CBWHI, HLWHI -- white, "bright" white, highlight white
#
# Modifiers available:
#
# CBON - activate bright
# CDON - activate dim
# ULON - activate underline
# RVON - activate reverse (switch foreground and background)
# SKON - activate strikethrough
# 
# Resets available:
#
# CNORM -- turn off bright or dim, without affecting other modifiers
# ULOFF -- turn off highlighting
# RVOFF -- turn off reverse colours
# SKOFF -- turn off strikethrough
# HLOFF -- turn off highlight
#
# CDEF -- turn off all colours and modifiers (switches to the terminal default)
#
# Note that highlight and underline must be applied or re-applied after specifying a colour.
#
# If the session is detected as being in a pipe, colours will be turned off.
#   You can override this by calling `colours:check --color=always` at the start of your script
#
#
# /!\ SPELLING /!\
#
# For historic reasons, "colours.sh" was named using British spelling; however some options use American spelling to match expectations from using other tools like `ls` for example.
#
# Consider that in the future, this will likely be changed for consistency - this library would become fully Ameriquified and the library renamed to 'colors.sh' and all functions will start with 'color:'.
#
###/doc

### colours:check ARGS ... Usage:bbuild
#
# Check the args to see if there's a `--color=always` or `--color=never`
#   and reload the colours appropriately
#
#   main() {
#       colours:check "$@"
#
#       echo "${CGRN}Green only in tty or if --colours=always !${CDEF}"
#   }
#
#   main "$@"
#
# Note use of American spelling in the option itself.
#
###/doc
colours:check() {
    if [[ "$*" =~ --color=always ]]; then
        COLOURS_ON=true
    elif [[ "$*" =~ --color=never ]]; then
        COLOURS_ON=false
    fi

    colours:define
    return 0
}

### colours:set CODE Usage:bbuild
# Set an explicit colour code - e.g.
#
#   echo "$(colours:set "33;2")Dim yellow text${CDEF}"
#
# See SGR Colours definitions
#   <https://en.wikipedia.org/wiki/ANSI_escape_code#SGR_(Select_Graphic_Rendition)_parameters>
###/doc
colours:set() {
    # We use `echo -e` here rather than directly embedding a binary character
    if [[ "$COLOURS_ON" = false ]]; then
        return 0
    else
        echo -en "\033[${1}m"
    fi
}

### colours:pipe CODE Usage:bbuild
#
# Prints a colourisation byte sequence using the provided number, then writes the pipe stream, and then writes a reset sequence (default is '0' to reset colours).
#
###/doc
colours:pipe() {
    . <(args:use:local colourint ?reset -- "$@") ; 
    if [[ "$COLOURS_ON" = true ]]; then
        colours:set "$colourint"
        cat -
        colours:set "${reset:-0}"
    fi
}

colours:define() {

    # Shorthand colours

    export CBLA="$(colours:set "30")"
    export CRED="$(colours:set "31")"
    export CGRN="$(colours:set "32")"
    export CYEL="$(colours:set "33")"
    export CBLU="$(colours:set "34")"
    export CPUR="$(colours:set "35")"
    export CTEA="$(colours:set "36")"
    export CWHI="$(colours:set "37")"

    export CBBLA="$(colours:set "1;30")"
    export CBRED="$(colours:set "1;31")"
    export CBGRN="$(colours:set "1;32")"
    export CBYEL="$(colours:set "1;33")"
    export CBBLU="$(colours:set "1;34")"
    export CBPUR="$(colours:set "1;35")"
    export CBTEA="$(colours:set "1;36")"
    export CBWHI="$(colours:set "1;37")"

    export HLBLA="$(colours:set "40")"
    export HLRED="$(colours:set "41")"
    export HLGRN="$(colours:set "42")"
    export HLYEL="$(colours:set "43")"
    export HLBLU="$(colours:set "44")"
    export HLPUR="$(colours:set "45")"
    export HLTEA="$(colours:set "46")"
    export HLWHI="$(colours:set "47")"

    # Modifiers
    
    export CBON="$(colours:set "1")"
    export CDON="$(colours:set "2")"
    export ULON="$(colours:set "4")"
    export RVON="$(colours:set "7")"
    export SKON="$(colours:set "9")"

    # Resets

    export CBNRM="$(colours:set "22")"
    export HLOFF="$(colours:set "49")"
    export ULOFF="$(colours:set "24")"
    export RVOFF="$(colours:set "27")"
    export SKOFF="$(colours:set "29")"

    export CDEF="$(colours:set "0")"

}

### colours:remove Usage:help
# Pipe function to remove ANSI colour bytes
###/doc
colours:remove() {
    local _b=$'\033'
    sed -r "s/${_b}\[[0-9;]+m//g"
}

colours:auto() {
    if tty:is_pipe ; then
        COLOURS_ON=false
    else
        COLOURS_ON=true
    fi

    colours:define
    return 0
}

colours:auto

##bash-libs: out.sh @ 0400607e (2.1.17)

### Console output handlers Usage:bbuild
#
# Write data to console stderr using colouring
#
###/doc

### out:info MESSAGE Usage:bbuild
# print a green informational message to stderr
###/doc
function out:info {
    echo "$CGRN$*$CDEF" 1>&2
}

### out:warn MESSAGE Usage:bbuild
# print a yellow warning message to stderr
###/doc
function out:warn {
    echo "${CBYEL}WARN: $CYEL$*$CDEF" 1>&2
}

### out:defer MESSAGE Usage:bbuild
# Store a message in the output buffer for later use
###/doc
function out:defer {
    OUTPUT_BUFFER_defer[${#OUTPUT_BUFFER_defer[@]}]="$*"
}

# Internal
function out:buffer_initialize {
    OUTPUT_BUFFER_defer=(:)
}
out:buffer_initialize

### out:flush HANDLER ... Usage:bbuild
#
# Pass the output buffer to the command defined by HANDLER
# and empty the buffer
#
# Examples:
#
# 	out:flush echo -e
#
# 	out:flush out:warn
#
# (escaped newlines are added in the buffer, so `-e` option is
#  needed to process the escape sequences)
#
###/doc
function out:flush {
    [[ -n "$*" ]] || out:fail "Did not provide a command for buffered output\n\n${OUTPUT_BUFFER_defer[*]}"

    [[ "${#OUTPUT_BUFFER_defer[@]}" -gt 1 ]] || return 0

    for buffer_line in "${OUTPUT_BUFFER_defer[@]:1}"; do
        "$@" "$buffer_line"
    done

    out:buffer_initialize
}

### out:fail [CODE] MESSAGE Usage:bbuild
# print a red failure message to stderr and exit with CODE
# CODE must be a number
# if no code is specified, error code 127 is used
###/doc
function out:fail {
    local ERCODE=127
    local numpat='^[0-9]+$'

    if [[ "$1" =~ $numpat ]]; then
        ERCODE="$1"; shift || :
    fi

    echo "${CBRED}ERROR FAIL: $CRED$*$CDEF" 1>&2
    exit $ERCODE
}

### out:error MESSAGE Usage:bbuild
# print a red error message to stderr
#
# unlike out:fail, does not cause script exit
###/doc
function out:error {
    echo "${CBRED}ERROR: ${CRED}$*$CDEF" 1>&2
}

##bash-libs: askuser.sh @ 0400607e (2.1.17)

### askuser Usage:bbuild
# Present the user with questions on stderr
###/doc

yespat='^(yes|YES|y|Y)$'
numpat='^[0-9]+$'
rangepat='[0-9]+,[0-9]+'
listpat='^[0-9 ]+$'
blankpat='^ *$'

### askuser:confirm Usage:bbuild
# Ask the user to confirm a closed question. Defaults to no
#
# returns 0 on successfully match 'y' or 'yes'
# returns 1 otherwise
###/doc
function askuser:confirm {
    read -p "$* [y/N] > " 1>&2
    if [[ "$REPLY" =~ $yespat ]]; then
        return 0
    else
        return 1
    fi
}

### askuser:ask Usage:bbuild
# Ask the user to provide some text
#
# Echoes out the entered text
###/doc
function askuser:ask {
    read -p "$* : " 1>&2
    echo "$REPLY"
}

### askuser:password Usage:bbuild
# Ask the user to enter a password (does not echo what is typed)
#
# Echoes out the entered text
###/doc
function askuser:password {
    read -s -p "$* : " 1>&2
    echo >&2
    echo "$REPLY"
}

### askuser:choose_multi Usage:bbuild
# Allows the user to choose from multiple choices
#
# askuser:chose_multi MESG CHOICESTRING
#
#
# MESG is a single string token that will be displayed as prompt
#
# CHOICESTRING is a comma-separated, or newline separated, or "\\n"-separated token string
#
# Equivalent strings include:
#
# * `"a\\nb\\nc"` - quoted and explicit newline escapes
# * `"a,b,c"` - quoted and separated with commas
# * `a , b , c` - not quoted, separated by commas
# * `a`, `b` and `c` on their own lines
#
# User input:
#
# User can choose by selecting
#
# * a single item by number
# * a range of numbers (4,7 for range 4 to 7)
# * or a string that matches the pattern
#
# All option lines that match will be returned, one per line
#
# If the user selects nothing, then function returns 1 and an empty stdout
###/doc
function askuser:choose_multi {
    local mesg=$1; shift || :
    local choices=$(echo "$*"|sed -r 's/ *, */\n/g')

    out:info "$mesg:" 
    local choicelist="$(echo -e "$choices"|grep -E '^' -n| sed 's/:/: /')"
    echo "$choicelist" 1>&2
    
    local sel=$(askuser:ask "Choice")
    if [[ "$sel" =~ $blankpat ]]; then
        return 1

    elif [[ "$sel" =~ $numpat ]] || [[ "$sel" =~ $rangepat ]]; then
        echo -e "$choices" | sed -n "$sel p"
    
    elif [[ "$sel" =~ $listpat ]]; then
        echo "$choicelist" | grep -E "^${sel// /|}:" | sed -r 's/^[0-9]+: //'

    else
        echo -e "$choices"  |grep -E "$(echo "$sel"|tr " " '|')"
    fi
    return 0
}

### askuser:choose Usage:bbuild
# Ask the user to choose an item
#
# Like askuser:choose_multi, but will loop if the user selects more than one item
#
# If the user provides no entry, returns 1
#
# If the user chooses one item, that item is echoed to stdout
###/doc
function askuser:choose {
    local mesg=$1; shift || :
    while true; do
        local thechoice="$(askuser:choose_multi "$mesg" "$*")"
        local lines=$(echo -n "$thechoice" | grep '$' -c)
        if [[ $lines = 1 ]]; then
            echo "$thechoice"
            return 0
        elif [[ $lines = 0 ]]; then
            return 1
        else
            out:warn "Too many results"
        fi
    done
}
##bash-libs: abspath.sh @ 0400607e (2.1.17)

### abspath:path RELATIVEPATH [ MAX ] Usage:bbuild
# Returns the absolute path of a file/directory
#
# MAX defines the maximum number of "../" relative items to process
#   default is 50
###/doc

function abspath:path {
    local workpath="$1" ; shift || :
    local max="${1:-50}" ; shift || :

    if [[ "${workpath:0:1}" != "/" ]]; then workpath="$PWD/$workpath"; fi

    workpath="$(abspath:collapse "$workpath")"
    abspath:resolve_dotdot "$workpath" "$max" | sed -r 's|(.)/$|\1|'
}

function abspath:collapse {
    echo "$1" | sed -r 's|/\./|/|g ; s|/\.$|| ; s|/+|/|g'
}

function abspath:resolve_dotdot {
    local workpath="$1"; shift || :
    local max="$1"; shift || :

    # Set a limit on how many iterations to perform
    # Only very obnoxious paths should fail
    local obnoxious_counter
    for obnoxious_counter in $(seq 1 $max); do
        # No more dot-dots - good to go
        if [[ ! "$workpath" =~ /\.\.(/|$) ]]; then
            echo "$workpath"
            return 0
        fi

        # Starts with an up-one at root - unresolvable
        if [[ "$workpath" =~ ^/\.\.(/|$) ]]; then
            return 1
        fi

        workpath="$(echo "$workpath"|sed -r 's@[^/]+/\.\.(/|$)@@')"
    done

    # A very obnoxious path was used.
    return 2
}

##bash-libs: this.sh @ 0400607e (2.1.17)

### this: Info about the current command Usage:bbuild
#
# Get information about the current running app.
#
# Additional to the documented functions, there are three environment variables:
#
# * `THIS_basename` : the plain name of the currently running script
# * `THIS_dirname` : the absolute path to the script's containing directory
# * `THIS_scriptpath` : the absolute path to the script
#
###/doc

### this:bin Usage:bbuild
# The file name of the running script, without its path
###/doc
function this:bin {
    if [[ -n "${BBRUN_SCRIPT:-}" ]]; then
        basename "$BBRUN_SCRIPT"
    else
        basename "$0"
    fi
}

### this:bindir Usage:bbuild
# The absolute path of the directory in which the command is running
###/doc
function this:bindir {
    if [[ -n "${BBRUN_SCRIPT:-}" ]]; then
        dirname "$BBRUN_SCRIPT"
    else
        abspath:path "$(dirname "$0")"
    fi
}

THIS_basename="$(this:bin)"
THIS_dirname="$(this:bindir)"
THIS_scriptpath="$THIS_dirname/$THIS_basename"

##bash-libs: runmain.sh @ 0400607e (2.1.17)

### runmain SCRIPTNAME FUNCTION [ARGUMENTS ...] Usage:bbuild
#
# Runs the function FUNCTION with ARGUMENTS, only if the runtime
# name of the script matches SCRIPTNAME
#
# This allows you include a main-like function in your library
# that only runs if you use your lib as an executable itself.
#
# For example, an image archiver could be:
#
# 	function archive_images {
# 		tar czf "$1.tgz" "$@"
# 	}
#
# 	runmain archiveimages.sh archive_images "$@"
#
# When included a different script, the runmain call does not fire the lib's function
#
# If the lib is compiled/made executable, and named "archiveimages.sh", the function runs.
#
# This is similar to `if __name__ == "__main__"` clauses in python
#
###/doc

function runmain {
    local required_name="$1"; shift || :
    local funcall="$1"; shift || :
    local scriptname="$THIS_basename"

    if [[ "$required_name" = "$scriptname" ]]; then
        "$funcall" "$@"
    fi
}

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

dockerq:dorm() {
    . <(args:use:local extractor -- "$@") ; 
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
