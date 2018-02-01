#!/bin/bash
#From https://bbs.archlinux.org/viewtopic.php?id=74780

cd $HOME/music && find . -type f -mtime -1  | egrep '\.mp3$|\.flac$' | awk '{ sub(/^\.\//, ""); print }' > $HOME/.mpd/playlists/newmusic.m3u
