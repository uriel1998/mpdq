#!/usr/bin/env bash

########################################################################
#
#  Adds music file BPMs to MPD's stickerfile.
#  Reads from the music file (and maybe eventually some databases?)
#
########################################################################

export SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

if [ -f "${SCRIPT_DIR}/mpdq.ini" ]; then
    ConfigFile="${SCRIPT_DIR}/mpdq.ini"
else
    ConfigFile="${ConfigDir}/mpdq.ini"
fi

MPDBASE=""
MPD_HOST=""
MPD_PASS=""
MPD_PORT=""
MUSICINFO=""

# Noisy feedback or not?
LOUD=1

host_arg=""
grep_bin=$(which grep)

# Optional directory restriction.
# This will eventually contain an MPD-relative directory.
PROCESS_DIR=""

########################################################################
# Functions
########################################################################

function loud() {
    if [ "$LOUD" -eq 1 ]; then
        echo "$@"
    fi
}

function usage() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Options:
    --dir PATH       Only process files beneath PATH.
                     PATH may be either:
                       - relative to the MPD music directory
                       - an absolute path beneath the MPD music directory

Examples:
    $(basename "$0")
    $(basename "$0") --dir "Rock/Industrial"
    $(basename "$0") --dir "/home/steven/Music/Rock/Industrial"
    $(basename "$0") --dir="Rock/Industrial"

EOF
}

function parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --dir)
                if [[ -z "${2:-}" ]]; then
                    echo "[error] --dir requires a pathname" >&2
                    exit 1
                fi
                PROCESS_DIR="$2"
                shift 2
                ;;

            --dir=*)
                PROCESS_DIR="${1#*=}"

                if [[ -z "$PROCESS_DIR" ]]; then
                    echo "[error] --dir requires a pathname" >&2
                    exit 1
                fi

                shift
                ;;

            -h|--help)
                usage
                exit 0
                ;;

            *)
                echo "[error] Unknown argument: $1" >&2
                usage >&2
                exit 1
                ;;
        esac
    done
}

function read_variables() {
    local config=""

    if [ -f "$ConfigFile" ]; then
        config=$(cat "$ConfigFile")
    else
        loud "Configuration file not found; using defaults."
    fi

    # If there's no config file or a line is malformed or missing,
    # sub in the default value.
    MPDBASE="$(
        echo "$config" |
            "${grep_bin}" -e "^musicdir=" |
            cut -d = -f 2- ||
        cat "$XDG_CONFIG_HOME/mpd/mpd.conf" |
            "${grep_bin}" "^music" |
            cut -d'"' -f2 ||
        echo "$HOME/Music"
    )"

    MPD_HOST="$(
        echo "$config" |
            "${grep_bin}" -e "^mpdserver=" |
            cut -d = -f 2- ||
        echo localhost
    )"

    MPD_PASS=$(
        echo "$config" |
            "${grep_bin}" -e "^mpdpass=" |
            cut -d = -f 2-
    )

    MPD_PORT=$(
        echo "$config" |
            "${grep_bin}" -e "^mpdport=" |
            cut -d = -f 2- ||
        echo 6600
    )

    ####################################################################
    # Determine where/how to assess BPM
    ####################################################################

    if [[ $(echo "$config" | "${grep_bin}" -c -e "^musicinfo=") -gt 0 ]]; then

        MUSICINFO=$(
            echo "$config" |
                "${grep_bin}" -e "^musicinfo=" |
                cut -d = -f 2-
        )

    else
        if command -v ffprobe >/dev/null 2>&1; then
            MUSICINFO=ffprobe

        elif command -v exiftool >/dev/null 2>&1; then
            MUSICINFO=exiftool

        elif command -v eyeD3 >/dev/null 2>&1; then
            MUSICINFO=eyeD3

        else
            MUSICINFO=""
        fi
    fi

    set_host_arg
}

function set_host_arg() {
    # In case the password is already set in environment.
    if [ -n "$MPD_PASS" ] && [[ "$MPD_HOST" != *"@"* ]]; then
        host_arg="$MPD_PASS@$MPD_HOST"
    else
        host_arg="$MPD_HOST"
    fi
}

function normalize_process_dir() {
    local base_real
    local dir_real

    # No --dir means process the entire MPD library.
    if [[ -z "$PROCESS_DIR" ]]; then
        return 0
    fi

    ####################################################################
    # Absolute pathname
    ####################################################################

    if [[ "$PROCESS_DIR" = /* ]]; then

        base_real=$(realpath -m "$MPDBASE")
        dir_real=$(realpath -m "$PROCESS_DIR")

        # --dir points to MPDBASE itself.
        if [[ "$dir_real" == "$base_real" ]]; then
            PROCESS_DIR=""
            loud "[info] Processing entire MPD music directory."
            return 0
        fi

        # Absolute directory lies beneath MPDBASE.
        if [[ "$dir_real" == "$base_real/"* ]]; then

            # Convert:
            #
            # /home/steven/Music/Rock/Industrial
            #
            # into:
            #
            # Rock/Industrial
            #
            PROCESS_DIR="${dir_real#"$base_real"/}"

        else
            echo "[error] Directory is outside the MPD music directory:" >&2
            echo "        Requested: $PROCESS_DIR" >&2
            echo "        MPD base:  $MPDBASE" >&2
            exit 1
        fi

    ####################################################################
    # MPD-relative pathname
    ####################################################################

    else
        # Remove an optional leading ./
        PROCESS_DIR="${PROCESS_DIR#./}"

        # Remove trailing slash.
        PROCESS_DIR="${PROCESS_DIR%/}"

        # Reject relative path traversal outside MPDBASE.
        dir_real=$(realpath -m "${MPDBASE}/${PROCESS_DIR}")
        base_real=$(realpath -m "$MPDBASE")

        if [[ "$dir_real" == "$base_real" ]]; then
            PROCESS_DIR=""

        elif [[ "$dir_real" == "$base_real/"* ]]; then
            # Normalize things such as:
            #
            # Rock/../Jazz
            #
            # into:
            #
            # Jazz
            PROCESS_DIR="${dir_real#"$base_real"/}"

        else
            echo "[error] Directory resolves outside the MPD music directory:" >&2
            echo "        Requested: $PROCESS_DIR" >&2
            echo "        MPD base:  $MPDBASE" >&2
            exit 1
        fi
    fi

    ####################################################################
    # Verify the filesystem directory exists
    ####################################################################

    if [[ -n "$PROCESS_DIR" ]] &&
       [[ ! -d "${MPDBASE}/${PROCESS_DIR}" ]]; then

        echo "[error] Directory does not exist:" >&2
        echo "        ${MPDBASE}/${PROCESS_DIR}" >&2
        exit 1
    fi

    loud "[info] Restricting processing to: ${PROCESS_DIR:-/}"
}

function check_write_bpm() {
    # Get the BPM and write the BPM.
    # Takes MPD-relative file_path as $1.

    local file_path="${1}"
    local sticker_bpm=""
    local file_bpm=""
    local full_filepath=""

    sticker_bpm=$(
        mpc \
            --host "${host_arg}" \
            --port "${MPD_PORT}" \
            sticker "${file_path}" list |
            grep -e "^bpm=" |
            awk -F '=' '{print $2}'
    )

    if [ -z "$sticker_bpm" ]; then

        full_filepath="${MPDBASE}/${file_path}"

        if [ -f "${full_filepath}" ]; then

            case "$MUSICINFO" in

                ffprobe)
                    file_bpm=$(
                        ffprobe "${full_filepath}" 2>&1 |
                            grep bpm |
                            awk -F 'bpm: ' '{print $2}'
                    )
                    ;;

                exiftool)
                    file_bpm=$(
                        exiftool "${full_filepath}" |
                            grep "Beats Per Minute" |
                            awk -F ': ' '{print $2}'
                    )
                    ;;

                eyeD3)
                    file_bpm=$(
                        eyeD3 "${full_filepath}" |
                            grep bpm -A1 |
                            tail -n 1
                    )
                    ;;

                *)
                    loud "[warn] No supported music metadata reader found."
                    return
                    ;;
            esac
        fi

        if [ -n "${file_bpm}" ]; then

            # Remove decimal portion.
            file_bpm="${file_bpm%%.*}"

            mpc \
                --host "${host_arg}" \
                --port "${MPD_PORT}" \
                sticker "${file_path}" \
                set bpm "${file_bpm}" \
                >/dev/null 2>&1

            loud "[info] Added bpm of ${file_bpm} for ${file_path}"

        else
            loud "[warn] BPM not found for ${full_filepath}"

            printf '%s\n' "${full_filepath}" \
                >> "${SCRIPT_DIR}/no_bpm_found.txt"
        fi

    else
        loud "[info] Found BPM in stickerfile!"
    fi
}

########################################################################
# Main
########################################################################

parse_args "$@"

read_variables

normalize_process_dir

########################################################################
# Get list of files
########################################################################

if [[ -n "$PROCESS_DIR" ]]; then

    mapfile -t FILELIST_ARRAY < <(
        mpc \
            --host "${host_arg}" \
            --port "${MPD_PORT}" \
            listall "$PROCESS_DIR" |
            shuf
    )

else

    mapfile -t FILELIST_ARRAY < <(
        mpc \
            --host "${host_arg}" \
            --port "${MPD_PORT}" \
            listall |
            shuf
    )

fi

########################################################################
# Process files
########################################################################

i=0

while [ "$i" -lt "${#FILELIST_ARRAY[@]}" ]; do

    file_path="${FILELIST_ARRAY[$i]}"

    loud "[info] Processing: $((i + 1)) of ${#FILELIST_ARRAY[@]} :: ${file_path}"

    check_write_bpm "${file_path}"

    ((i++))
done
