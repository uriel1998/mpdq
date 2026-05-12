# mpdq

`mpdq` is a Bash script that keeps an MPD queue filled using weighted genre
selection from your existing music library.

![mpdq logo](https://raw.githubusercontent.com/uriel1998/mpdq/master/mpdq-open-graph.png "logo")

![mpdq in action](https://raw.githubusercontent.com/uriel1998/mpdq/master/mpdq.gif "mpdq in action")

## About

Each run checks your current MPD playlist length and adds tracks until the queue
reaches `queuesize`. Selection is based on MPD genres plus a simple instruction
file of `genre=weight` entries.

This branch is the single-run version. It does not stay resident and it does not
watch MPD continuously. Run it directly or from something like `watch` or a
systemd timer.

`mpdq` also keeps short play logs so it can avoid immediate repeats of:

* the same track
* the same album
* the same artist

## Requirements

The script depends on standard Unix tools plus MPD itself:

* `bash`
* `mpd`
* `mpc`
* `grep`
* `sed`
* `awk`
* `shuf`
* `wc`
* `ps`
* `tail`
* `mktemp`

## Configuration

`mpdq` reads its config from:

`$XDG_CONFIG_HOME/mpdq/mpdq.ini`

If `XDG_CONFIG_HOME` is unset, that becomes:

`~/.config/mpdq/mpdq.ini`

The file is simple `key=value` text, not an INI file with sections. Example:

```ini
musicdir=/directory/to/music
mpdserver=localhost
mpdport=6600
mpdpass=
songlength=900
queuesize=10
rotate_time=8
no_replay_rotate=8
album_mins=15
artist_mins=15
genres_exclude_album_check=Sound Clip,Classical
```

Config keys:

* `musicdir`: base path of the music library as seen by the machine running `mpdq`
* `mpdserver`: MPD host name
* `mpdport`: MPD port
* `mpdpass`: optional MPD password
* `songlength`: maximum song length in seconds
* `queuesize`: minimum playlist size to maintain
* `rotate_time`: hours to keep the per-genre play log
* `no_replay_rotate`: hours to keep the no-repeat song log
* `album_mins`: minimum minutes before repeating an album
* `artist_mins`: minimum minutes before repeating an artist
* `genres_exclude_album_check`: comma-separated genres that skip album/artist cooldown checks

Runtime files are stored under XDG state/cache directories:

* `$XDG_STATE_HOME/mpdq/playedsongs.log`
* `$XDG_STATE_HOME/mpdq/playedsongs2.log`
* `$XDG_STATE_HOME/mpdq/mpdq_cmd`

## Instruction Files

Instruction files are optional plain text files with one `genre=weight` entry per
line:

```text
Default=1
Rock=3
Classical=0
```

Rules:

* `Default` applies to genres not listed explicitly
* higher weights make a genre more likely to be chosen
* a weight of `0` disables that genre
* genre names must match MPD's genre names exactly

If no `-c` file is supplied, `mpdq` will use:

`$XDG_CONFIG_HOME/mpdq/default.cfg`

when that file exists. Otherwise it falls back to `Default=1`.

`mpdq -e` creates a starter instruction file at:

`$XDG_CONFIG_HOME/mpdq/default_example.cfg`

## Usage

```text
mpdq [-c /path/to/instructions] [-e] [-f] [-h] [-k] [-l|--loud] [-r value]
```

Options:

* `-c FILE`: use a specific instruction file
* `-e`: create an example instruction file from MPD's current genre list
* `-f`: force MPD settings required by `mpdq`
* `-h`: show help
* `-k`: send a kill command to an already running `mpdq`
* `-l`, `--loud`: print progress messages
* `-r VALUE`: write a relay command or alternate instruction file path for a running process

Typical single-run usage:

```bash
mpdq -f
mpdq -c ~/.config/mpdq/default.cfg
watch -n 60 mpdq -c ~/.config/mpdq/default.cfg
```

## MPD Playback Settings

`mpdq` will only queue music when MPD is in this state:

* `random` is `off`
* `repeat` is `off`
* `consume` is `on`

If those settings do not match, the script exits without changing the queue.
`-f` applies the required `consume` and `random` settings; `repeat` still needs
to be off.

## Notes

The script talks to MPD over the network, but it also verifies selected files
against `musicdir`, so the filesystem layout must match what MPD reports.

This branch still contains relay and PID handling for a longer-running mode, but
the primary behavior here is single-run queue filling.
