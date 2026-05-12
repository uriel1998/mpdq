# Changelog

This file now summarizes newer history by release and keeps the older
commit-by-commit notes for pre-`2.0` development.

## 2026-05-12

### Current development

Based on local branch work after `2.3.0`, including commits such as
`50cde86`, `a9d41a5`, `cd27460`, `cd188bd`, `1d661be`, `739c422`,
`27902b1`, `bdfe45e`, `f78111a`, and `db2abaa`.

* Preferred local script-directory config, state, and cache locations while
  keeping XDG and home-directory fallbacks.
* Fixed MPD host handling so passworded and passwordless connections now build
  consistently through one code path, including the `-f` path and station mode.
* Removed the broken relay-file control path and the corresponding stale
  help/documentation references.
* Reworked station mode so it now loads the chosen station config directly,
  rebuilds weighted genre choices before filling the queue, and supports the
  interactive station chooser cleanly.
* Fixed instruction-file selection so `-c` once again accepts explicit files
  from arbitrary paths instead of misrouting them into station mode.
* Fixed several selection and cooldown bugs, including:
  the malformed artist cooldown comparison,
  inverted `genres_exclude_album_check` handling,
  and missing `Default=1` in generated example configs.
* Tightened the emergency no-match fallback so exhausting all options rotates
  both logs with progressively shorter lookback windows until a valid song is
  found, then resets the emergency state.
* Updated the script help and README to match the current single-run and
  station-selection behavior.

## 2025-05-31

### Development branch sync

* Merged `master` back into `dev` after the `2.3.0` work so the branch carried
  the current rewrite, weighting fixes, and MPD metadata changes forward.

## 2.3.0 - 2024-12-13

Based on commits `0879864`, `259f290`, `8a791d3`, `54ab63b`, `f4d4211`, and the
follow-up version commit `f821361`.

* Removed the `ffprobe` and `exiftool` dependency path and now pulls duration,
  album, and artist data from MPD itself through `mpc`.
* Simplified filename handling during selection and queue insertion.
* Fixed a significant bug in tracking how many times a genre or track had
  already been used.
* Fixed default weight parsing when `Default` is missing or spelled in lowercase.

## 2.2.0 - 2024-04-22

Based on commits `c0c5be9`, `056f847`, `63d3977`, `56df9c3`, and `f802850`.

* Added the longer no-repeat log used for "radio station" behavior so the same
  song can be kept out of rotation for a separate, longer window.
* Tightened instruction matching so weight lookups and play counts use the same
  exact-match behavior.
* Fixed duplicate instruction handling so repeated genre lines no longer break
  weight parsing.

## 2.1.1 - 2024-02-03

Based on commit `35e7965`.

* Documentation update for the `2.1.0` weighting rewrite.

## 2.1.0 - 2024-02-03

Based on commits `6d35816`, `80d8822`, `6423ab2`, `adf3cd4`, and `254f56f`.

* Added weighting back into the rewritten selector by expanding genre choices
  according to configured weight.
* Continued stabilizing the single-run selection loop introduced in `2.0.0`.

## 2.0.2 - 2024-02-03

Based on commits `dc5669a` and `e6097d9`.

* Fixed duration parsing so tracks with hour-length timestamps are filtered
  correctly.
* Added fallback handling for incomplete metadata so album cooldown tracking can
  fall back to title when album data is missing.

## 2.0.1 - 2024-02-02

Based on commit `7e33391`.

* Documentation-only follow-up release after `2.0.0`.

## 2.0.0 - 2024-02-02

Based on the `2.0.0beta` rewrite line through merge commit `32c64ab`, including
commits such as `78627d3`, `17a2228`, `bf1fdbb`, `dbd50f5`, `fa8a24b`,
`966fe2d`, `57913e5`, `c93e91f`, and `ab8fa70`.

* Rewrote `mpdq` from the older loop-oriented model into the current single-run
  queue filler.
* Moved to the current XDG-style config and state layout and kept relay support
  for command handoff.
* Reworked config and instruction parsing to handle exact `genre=weight`
  matching, missing instruction files, missing default values, and genre names
  with spaces.
* Added the current per-run selection loop that keeps queueing until MPD reaches
  `queuesize`.
* Added cooldown bypass support for configured genres that should skip album and
  artist repeat checks.
* Restored playback-state gating and added `-f` so MPD can be forced into the
  required `consume on` / `random off` state before queueing.

The longer path to this rewrite also included earlier 2022 development work:

* portable lookup for `grep` on systems where it is not in the expected path
* `--loud` / `-l` output mode for debugging and progress reporting
* root/XDG handling for container-style runs
* several attempts to remove subshell and FIFO issues before settling on the
  current simpler flow

## 2.0.0beta - 2024-02-02

Based on commit `aa455bb` and the immediately preceding rewrite commits.

* First public snapshot of the rewritten single-run branch before the final
  `2.0.0` merge and docs pass.

## Legacy Notes Through 1.5

* [2022-05-21 17:25:29 CDT] - docs; note file path changes for config directories HEAD -> master, tag: 1.5
* [2022-05-21 17:23:27 CDT] - default instruction file option gitlab/master, github/master, github/HEAD, fc/master
* [2022-05-16 19:19:51 CDT] - selection of infotool
* [2022-05-16 18:59:41 CDT] - for some reason didn't want to exit the subshell...
* [2022-05-16 16:08:15 CDT] - XDG_STATE_HOME/mpdq if doesn't exist, subbed ${StateDir} in
* [2022-05-16 17:02:09 CDT] - pull request #6 from xeruf/fixes
* [2022-05-16 17:02:02 CDT] - branch 'master' into fixes
* [2022-05-16 16:59:27 CDT] - pull request #3 from xeruf/master
* [2022-05-16 16:59:16 CDT] - branch 'master' into master
* [2022-05-15 19:24:14 CDT] - readme
* [2022-05-14 19:04:16 CDT] - debug message; noted that artist time is filename dependent and needs changed
* [2022-05-14 18:30:52 CDT] - mp3info to last chance since it only does ID3v1
* [2022-05-14 18:20:47 CDT] - typo
* [2022-05-13 20:31:18 CDT] - configurable (and more sane) support for different info tools
* [2022-03-28 21:53:31 CDT] - a1 N 2022-03-28 21:53:31 -0400 Steven Saus         Missed a 2>/dev/null
* [2022-03-23 21:18:45 CDT] - changelog
* [2022-03-23 21:16:29 CDT] - some bugs with the implementation, removed constant errors if you didn't have mp3info or exiftool installed tag: 1.4
* [2022-03-23 20:49:32 CDT] - added along with auto-finding alternatives. Fixed a bug on the pausing bit.
* [2021-11-20 09:01:48 CDT] - work without passwords and simplify config reading
* [2021-11-20 08:39:39 CDT] - error at file end
* [2021-11-20 08:32:57 CDT] - & reformat code
* [2021-11-03 09:24:14 CDT] - I have learned the hard way about fast forwards, le sigh python
* [2021-11-03 09:22:38 CDT] - remote-tracking branch 'github'
* [2021-11-03 09:13:36 CDT] - 673a9cc N 2021-11-03 09:13:36 -0400 Steven Saus         .
* [2021-11-03 09:02:58 CDT] - aa13aaf N 2021-11-03 09:02:58 -0400 Steven Saus         docs
* [2021-11-03 08:59:24 CDT] - theme jekyll-theme-midnight
* [2021-11-03 08:58:00 CDT] - up docs
* [2021-11-03 08:55:10 CDT] - theme jekyll-theme-minimal
* [2021-11-03 09:20:16 CDT] - remote-tracking branch 'gitlab/master'
* [2021-11-03 13:19:43 CDT] - to fix docs
* [2021-11-03 09:13:36 CDT] - 9259c9b N 2021-11-03 09:13:36 -0400 Steven Saus         .
* [2021-11-03 09:02:58 CDT] - 00ef423 N 2021-11-03 09:02:58 -0400 Steven Saus         docs
* [2021-11-03 08:59:24 CDT] - theme jekyll-theme-midnight
* [2021-11-03 08:58:00 CDT] - up docs
* [2021-11-03 08:58:00 CDT] - up docs
* [2021-11-03 08:55:10 CDT] - theme jekyll-theme-minimal
* [2021-11-03 08:54:12 CDT] - up docs layout
* [2021-08-26 18:46:17 CDT] - some reason MPC hates me here.... oh well.
* [2020-12-14 14:32:57 CDT] - changelog
* [2020-12-14 14:31:39 CDT] - independent log for songs for no repeats tag: v1.3.0
* [2020-12-07 14:20:58 CDT] - update
* [2020-12-07 14:15:41 CDT] - find instead of mpc search so it stops overmatching tag: v1.2.2
* [2020-12-06 00:08:04 CDT] - changelog
* [2020-12-06 00:05:44 CDT] - escaping spaces in genre matching tag: v1.2.1
* [2020-12-05 17:12:05 CDT] - changelog file
* [2020-12-05 16:59:06 CDT] - docs tag: v1.2.0, triple-threat
* [2020-12-05 15:06:17 CDT] - the logrotation!
* [2020-12-04 21:04:05 CDT] - whole MESS of bugs squashed
* [2020-12-03 20:14:34 CDT] - really got that bug this time...
* [2020-12-03 20:06:59 CDT] - tracked down that stupid urinary bug
* [2020-12-03 20:01:39 CDT] - like the lookback for songtime is working...
* [2020-12-03 14:45:56 CDT] - code for artist matching
* [2020-11-29 17:07:14 CDT] - in length of song check using ffprobe
* [2020-11-12 17:53:51 CDT] - error with logrotation and genre matching tag: v1.1.1
* [2020-10-17 20:15:03 CDT] - sorting seems to be functioning properly
* [2020-10-17 19:06:05 CDT] - errors with genre matching
* [2020-10-14 13:11:50 CDT] - readme
* [2020-10-14 13:04:57 CDT] - option seems to be working - beta tag: v1.1.0-prerelease
* [2020-10-14 11:56:31 CDT] - out genre weighting addition
* [2020-10-11 22:12:34 CDT] - Pages
* [2020-10-11 21:21:55 CDT] - d3aa8e6 N 2020-10-11 21:21:55 -0400 Steven Saus         pages
* [2020-08-24 16:53:26 CDT] - error in README
* [2020-08-11 11:34:00 CDT] - tag: v1.0.0
* [2020-08-11 11:02:38 CDT] - in code to prevent multiple instances starting, and to keep from deleting the instruction file somehow...
* [2020-08-11 03:51:07 CDT] - the playing/pausing on start/exit with the reload changes
* [2020-08-11 02:26:16 CDT] - monit tweaks
* [2020-08-11 02:17:17 CDT] - systemd, monit, and fswatch instructions for reloading
* [2020-08-10 23:00:18 CDT] - debug code, now working properly. YAY!
* [2020-08-10 22:58:33 CDT] - needed to be $10 instead of $8 there...
* [2020-08-10 22:48:32 CDT] - typo
* [2020-08-10 22:36:45 CDT] - auto-pausing feature
* [2020-07-29 11:09:41 CDT] - think I've got a primitive weighting working here
* [2020-07-27 22:17:09 CDT] - to balance weighting for libraries with uneven collections
* [2020-06-21 15:51:58 CDT] - tweaks to readme
* [2020-06-21 14:06:28 CDT] - readme with blog link
* [2020-06-20 17:13:35 CDT] - typos
* [2020-06-20 17:06:56 CDT] - gif
* [2020-06-20 17:05:17 CDT] - song rotation, got a gif of it working
* [2020-06-20 14:13:37 CDT] - crap, I think it works.
* [2020-06-20 13:59:05 CDT] - newline issue with instruction file
* [2020-06-20 13:35:20 CDT] - the genre selection loop working
* [2020-06-20 13:29:41 CDT] - determining genre weights loop, whoops
* [2020-06-14 22:01:47 CDT] - stopping place
* [2020-06-14 22:00:40 CDT] - bit is still wonky, but other bits seem clear...
* [2020-06-14 16:25:18 CDT] - and example instruction tested
* [2020-06-14 16:15:04 CDT] - testing!
* [2020-06-14 14:10:58 CDT] - in reading in ini section
* [2020-06-14 08:30:52 CDT] - switch in filenames
* [2020-06-14 08:30:20 CDT] - graphical contents
* [2020-06-14 08:12:37 CDT] - on new Readme, moved old version to subdir
* [2020-06-13 19:48:54 CDT] - the skeleton together
* [2020-06-13 19:34:52 CDT] - commit and pseudocode of new flow
* [2020-02-18 22:42:39 CDT] - where I broke it while fixing other stuff tag: archive/bpm_version, bpm_version
* [2020-02-18 20:46:05 CDT] - error causing configuration to fail
* [2019-12-03 22:24:42 CDT] - and made -k more robust (and probably overkill)
* [2019-12-02 21:18:15 CDT] - with background processing and killing
* [2019-11-13 09:30:57 CDT] - BPM only option
* [2018-02-01 16:18:50 CDT] - error with non-local filesystems
* [2018-02-01 14:51:53 CDT] - the playlist generator
* [2017-11-13 20:20:57 CDT] - genre jumping by default.
* [2017-11-13 17:04:01 CDT] - overmatching
* [2017-11-12 21:08:48 CDT] - two places for password and host config
* [2017-11-12 20:43:27 CDT] - some parsing in the genre configuration
* [2017-11-12 20:14:33 CDT] - genre selection a bit cleaner, default match for genre you are matching
* [2017-11-12 19:45:49 CDT] - grep bug by using -F flag
* [2017-11-12 19:32:46 CDT] - to have exit with help menu
* [2017-11-12 19:27:55 CDT] - up code, adding todo
* [2017-11-12 19:23:34 CDT] - commit
* [2017-11-12 19:20:32 CDT] - commit
