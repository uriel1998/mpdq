#!/usr/bin/env bash

########################################################################
#
#  adds music file bpms to MPD's stickerfile.
#  Reads from the music file (and maybe eventually some databases?)
#
###########################################################################

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
# noisy feedback or not?
LOUD=1
host_arg=""
grep_bin=$(which grep)

########################################################################
# Functions
########################################################################

function loud() {
    if [ $LOUD -eq 1 ];then
        echo "$@"
    fi
}

function read_variables() {
    if [ -f "$ConfigFile" ];then
        config=$(cat "$ConfigFile")
    else
        loud "Configuration file not found; using defaults."
    fi
    # If there's no config file or a line is malformed or missing, sub in the default value

    MPDBASE="$(echo "$config" | ${grep_bin} -e "^musicdir=" | cut -d = -f 2- ||
        cat "$XDG_CONFIG_HOME/mpd/mpd.conf" | ${grep_bin} "^music" | cut -d'"' -f2 ||
        echo $HOME/Music)"
    MPD_HOST="$(echo "$config" | ${grep_bin} -e "^mpdserver=" | cut -d = -f 2- || echo localhost)"
    MPD_PASS=$(echo "$config" | ${grep_bin} -e "^mpdpass=" | cut -d = -f 2-)
    MPD_PORT=$(echo "$config" | ${grep_bin} -e "^mpdport=" | cut -d = -f 2- || echo 6600)
    # Determining where/how to assess song length
    if [[ `echo "$config" | ${grep_bin} -c -e "^musicinfo="` -gt 0 ]];then
        MUSICINFO=$(echo "$config" | ${grep_bin} -e "^musicinfo=" | cut -d = -f 2- )
    else
        if [ -f $(which ffprobe) ];then
            MUSICINFO=ffprobe
        else
            if [ -f $(which exiftool) ];then
                MUSICINFO=exiftool
            else
                if [ -f $(which eyeD3) ];then
                    MUSICINFO=eyeD3
                else
                    MUSICINFO=""
                fi
            fi
        fi
    fi
    set_host_arg
}

function set_host_arg() {
    # in case the password is already set in environment
    if [ -n "$MPD_PASS" ] && [ "$MPD_HOST" != *"@"* ]; then
        host_arg="$MPD_PASS@$MPD_HOST"
    else
        host_arg="$MPD_HOST"
    fi
}

function check_write_bpm() {
    # get the bpm, write the bpm. Takes file_path as $1
    local file_path="${1}"
    local sticker_bpm
    local file_bpm
    local full_filepath

    sticker_bpm=$(mpc --host "${host_arg}" --port "${MPD_PORT}" sticker "${file_path}" list | grep -e "^bpm=" | awk -F '=' '{print $2}')
    if [ -z "$sticker_bpm" ];then
        full_filepath="${MPDBASE}/${file_path}"
        if [ -f "${full_filepath}" ];then
            case "$MUSICINFO" in
                ffprobe)
                    file_bpm=$(ffprobe "${full_filepath}" 2>&1 | grep bpm | awk -F 'bpm: ' '{print $2}')
                    ;;

                exiftool)
                    file_bpm=$(exiftool "${full_filepath}" | grep "Beats Per Minute" | awk -F ': ' '{print $2}')
                    ;;
                eyeD3)
                    file_bpm=$(eyeD3 "${full_filepath}" | grep bpm -A1 | tail -n 1 )
                    ;;
            esac
        fi
        if [ ! -z "${file_bpm}" ];then
            file_bpm="${file_bpm%%.*}"  #remove decimal
            mpc --host "${host_arg}" --port "${MPD_PORT}" sticker "${file_path}" set bpm "${file_bpm}" >/dev/null 2>&1
            loud "[info] Added bpm of ${file_bpm} for ${file_path}"
        else
            loud "[warn] BPM not found for ${full_filepath}"
        fi
    else
        loud "[info] Found BPM in stickerfile!"
    fi
}



read_variables
mapfile -t FILELIST_ARRAY < <(mpc  --host "${host_arg}" --port "${MPD_PORT}" listall | shuf | head -50 )
i=0
while [ $i -lt ${#FILELIST_ARRAY[@]} ]; do
    file_path="${FILELIST_ARRAY[$i]}"
    loud "[info] Processing: $i of ${#FILELIST_ARRAY[@]} :: ${file_path} "
    # SEND TO PROCESSING FUNCTION
    check_write_bpm "${file_path}"
    ((i++))
done
