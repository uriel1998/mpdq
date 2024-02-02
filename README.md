# mpdq

Automatic MPD playlist or party mode creator to provide
weighted randomness while autoqueuing MPD 
without relying on external services.

![mpdq logo](https://raw.githubusercontent.com/uriel1998/mpdq/master/mpdq-open-graph.png "logo")

![mpdq in action](https://raw.githubusercontent.com/uriel1998/mpdq/master/mpdq.gif "mpdq in action")

### Change from prior versions! 

The program has been rewritten for simplicity and to avoid subprocesses; each run 
will add a configurable number of tracks to the queue. Adding a self-contained idle 
loop is in the roadmap.

## Contents
 1. [About](#1-about)
 2. [License](#2-license)
 3. [Prerequisites](#3-prerequisites)
 4. [Installation](#4-installation)
 5. [Setup](#5-setup)
 6. [Usage](#6-usage)
 7. [TODO](#7-todo)

***

## 1. About

`mpdq` is a auto-queing system for MPD to create a flexible and configurable 
"party mode" effect with randomization and (re)discovery of your own music. 
Inspired by the eclectic soundtracks of *Letterkenny*, *High Fidelity*, 
*Doom Patrol*, and many more.
(In-depth explanation at [my blog](https://ideatrash.net/?p=121759)).

`mpdq` will autoqueue random tracks from your existing music library,
with per-genre weighting and simple defaults.  

Because it uses `mpd`'s own data, new tracks and changes to your music library 
will be incorporated when `mpd` is updated.

## 2. License

This project is licensed under the MIT License. For the full license, see `LICENSE`.

## 3. Prerequisites

These are probably already installed or are easily available from your distro on
linux-like distros:  

* [mpd](https://www.musicpd.org/)
* [mpc](http://git.musicpd.org/cgit/master/mpc.git/)  
* [shuf](https://linux.die.net/man/1/shuf)
* [grep](http://en.wikipedia.org/wiki/Grep)  
* [bash](https://www.gnu.org/software/bash/)  
* [wc](https://www.computerhope.com/unix/uwc.htm)
* [bc](https://www.geeksforgeeks.org/bc-command-linux-examples/)
* [detox](http://detox.sourceforge.net/)

ONE or MORE of the following for artist and song information on your `$PATH`:

* [exiftool](https://www.exiftool.org/)
* [ffmpeg](https://ffmpeg.org/)

`mpdq` will attempt to use them automatically in the order listed.

## 4. Installation

Place mpdq.ini in $XDG_CONFIG_HOME/mpdq


```
[SERVER]
musicdir=/directory/to/music
mpdserver=localhost
mpdport=6600
mpdpass=hackme
songlength=15
queuesize=10
# in hours
rotate_time=1
# in minutes
album_mins=30
artist_mins=30
# Genres to exclude from the above two checks
genres_exclude_album_check=Sound Clip,Classical
musicinfo=/usr/bin/ffprobe
```

## 5. Setup

### From the INI file

`rotate_time` in the ini file defines how long mpdq keeps a log for in hours -- and helps define 
how often each genre will be played.  

`album_mins` and `artist_mins` will *separately* define the minimum interval 
*in minutes* before a specific album or artist will be played again.  This should 
be shorter than `rotate_time`.

`genres_exclude_album_check` is a list of genres where the `album_mins` and `artist_mins` 
checks will be *disabled*, for example, if you have a genre with only one or two artists or
albums in it.

### Instruction files

The behavior of `mpdq` is governed by simple instruction files, as many (or 
few) as you desire.  The location of the instruction file does not matter, and 
must be specified on the command line.  Without an instruction file, `mpdq` will 
just shuffle through your entire library with an equal weight to each genre. 

Each instruction file is a series of lines in the format `genre=weight` like so:

```
Default=1
Rock=3
Classical=0

```

That "weight" is the *maximum* number of times that genre will be played in 
the interval you put for `rotate_time` in the ini file. The `Default` line 
is applied to all genres that are not explicitly named in the instruction file.

In the example above, all genres will be played a maximum of *1* time per `rotate_time`,
except Rock, which *may* be played *up to* three times per `rotate_time`, and Classical, 
which will *never* be played per `rotate_time`. 

This allows for both very eclectic selections (as with the example above) or 
very focused selections, such as with the example below:

```
Default=0
Industrial=1
Gothic=1

```

**Capitalization Matters**

`mpdq` can also create an example instruction file with *all* genres listed so 
that you can check your genre names properly.  It won't *hurt* to have all the 
genres listed, but it is totally unneeded.

The instruction file should end in a newline. If it does not, `mpdq` will add 
one automatically.

If the instruction "default.cfg" exists in the configuration directory, it will 
automatically be used. If that file does not exist, the default value ("1") will 
be applied to all genres.


## 6. Usage

`mpdq [-d #][-c /path/to/file][-khe]`

`mpdq` has the following command line switches:

* -c : Which instruction file to use
* -d : Override the default priority in the instruction file
* -k : Kill a currently running `mpdq` process.
* -e : Create an example instruction file at $XDG_STATE_HOME/mpdq/example_instruction.
* -h : Show a short help message.
* --loud: Give more feedback to terminal (yes, this means the default is quiet mode)  

It should be run as a single run process or using the `watch` command (e.g. `watch -n 60 mpdq`).

With each run, `mpdq` will add `queuesize` (from the ini file) tracks to MPD queue 
and then exit.

* If `mpdq.ini` is set up properly, you can even just do "random mode" by running `mpdq` by itself, and setting the frequency using `-d`.
* If you've got `default.cfg` set up as well, you can just run `mpdq` with no switches.

Because you define the hostname, it does *not* have to be on the same machine
running MPD, but because it *does* check file existence, you'll have to have 
an identical music library structure.  For example, I use a shared NFS mount.

`mpdq` logs what songs it has played, and will not repeat the same song during 
the time specified in `mpdq.ini`.  It does *not* log songs played or added in 
any other way.

### Advanced Usage

With single-run mode, `mpdq` reads from the instruction file with each run. This 
means that you can create different instruction files and either copy them to 
`default.cfg` or use the `-c` switch to change your upcoming (random-ish) music. 


## 7. TODO
 
* Check for album artist when artist is not present or empty
* Add loop back in and utilize relay mechanism to change instruction file
* Double-check time calculations, particularly for songs > 60m
* Switch between loop mode and single-run mode
* Add in what to do when all genres run through in logrotate timeperiod
* Lighterweight way to handle log rotation, since I'm calling it frequently?
