#!/usr/bin/env bash
set -euo pipefail

# This script verifies the instruction files in a directory you pass and
# only preserves those genres that exist in mpd. It also removes those 
# which are otherwise empty.


if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <cfg-directory>" >&2
  exit 1
fi

target_dir=$1

if [[ ! -d "$target_dir" ]]; then
  echo "Error: '$target_dir' is not a directory" >&2
  exit 1
fi

log_file="$PWD/whatchanged.txt"
timestamp() {
  date '+%Y-%m-%d %H:%M:%S'
}

# Build a set of valid genres from MPD.
declare -A valid_genres
mpd_host=${MPD_HOST:-}
while IFS= read -r genre; do
  genre=${genre%$'\r'}
  [[ -n "$genre" ]] || continue
  valid_genres["$genre"]=1
done < <(mpc --host "$mpd_host" list genre)

if [[ ${#valid_genres[@]} -eq 0 ]]; then
  echo "Error: no genres returned by MPD" >&2
  exit 1
fi

# Process .cfg files directly in the specified directory.
while IFS= read -r -d '' cfg; do
  tmp_genres=$(mktemp)
  tmp_final=$(mktemp)
  kept_genres=0
  file_changed=0

  while IFS= read -r line || [[ -n "$line" ]]; do
    line=${line%$'\r'}

    if [[ "$line" == "Default=0" ]]; then
      continue
    fi

    if [[ -z "$line" ]]; then
      continue
    fi

    genre=${line%%=*}

    if [[ -n "${valid_genres[$genre]:-}" ]]; then
      printf '%s\n' "$line" >> "$tmp_genres"
      kept_genres=1
    else
      file_changed=1
      printf '[%s] %s: removed invalid genre line: %s\n' "$(timestamp)" "$cfg" "$line" >> "$log_file"
    fi
  done < "$cfg"

  if [[ $kept_genres -eq 0 ]]; then
    rm -f "$cfg"
    rm -f "$tmp_genres" "$tmp_final"
    printf '[%s] %s: removed file (no valid genres remain)\n' "$(timestamp)" "$cfg" >> "$log_file"
    continue
  fi

  {
    printf 'Default=0\n'
    cat "$tmp_genres"
  } > "$tmp_final"

  if cmp -s "$tmp_final" "$cfg"; then
    rm -f "$tmp_genres" "$tmp_final"
    continue
  fi

  cat "$tmp_final" > "$cfg"
  rm -f "$tmp_genres" "$tmp_final"

  if [[ $file_changed -eq 0 ]]; then
    printf '[%s] %s: file updated (normalized content)\n' "$(timestamp)" "$cfg" >> "$log_file"
  else
    printf '[%s] %s: file updated\n' "$(timestamp)" "$cfg" >> "$log_file"
  fi
done < <(find "$target_dir" -maxdepth 1 -type f -name '*.cfg' -print0 | sort -z)
