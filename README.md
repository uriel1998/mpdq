# mpdq

Automatic MPD playlist or party mode creator to provide complexity and 
randomness while autoqueuing MPD without relying on external services.

![mpdq logo](https://raw.githubusercontent.com/uriel1998/mpdq/master/mpdq-open-graph.png "logo")

![mpdq in action](https://raw.githubusercontent.com/uriel1998/mpdq/master/mpdq.gif "mpdq in action")


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
*Doom Patrol*, and many more.  (More explanation for *why* is at [my blog](https://ideatrash.net/?p=121759).  

`mpdq` will autoqueue random tracks from your existing music library, with 
(very) configurable weighting by genre and simple defaults.  

Because it uses `mpd`'s own data, new tracks and changes to your music library 
will be incorporated when `mpd` is updated.

If you are looking for the older, heaver, and BPM-using version of `mpdq`, 
those files are in the `bpm_version` directory of this repository.

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

## 4. Installation

* Create $HOME/.config/mpdq
* Place mpdq.ini in $HOME/.config/mpdq

This file (example provided) contains only the following lines:

```
musicdir=/directory/to/music
mpdserver=hostname.of.mpd
mpdport=6600
mpdpass=mpd_password
queuesize=10
hours=8
mode=simple  
songlength=15
```

`songlength` puts a cap on the duration of any chosen song to that many minutes.

`hours` and `mode` manage the size of queue that `mpdq` maintains and how many hours 
after playing a song that `mpdq` will *not* play it again.  Defaults are:

```
$HOME/Music
localhost
6600
(no password)
10
8
simple  
15
```

See below under [Setup](#5-setup) for the difference in "modes".

## 5. Setup

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

Rather than go through all the genres and subgenres of your music library and 
explicitly defining each one, the `Default` line assigns a weight to all genres 
not otherwise explictly named. Genres with higher number values will show up 
more often.  In the example above, all genres have a weight of "1" except for 
Rock and Classical.  Rock will show up more often, while Classical will not 
appear at all with a value of "0".

This allows for both very eclectic selections (as with the example above) or 
very focused selections, such as with the example below:

```
Default=0
Industrial=1
Gothic=1

```

**Capitalization Matters Here**

`mpdq` can also create an example instruction file with *all* genres listed so 
that you can check your genre names properly.  It won't *hurt* to have all the 
genres listed, but it is totally unneeded.

The instruction file should end in a newline. If it does not, `mpdq` will add 
one automatically.


### Mode

There are three possible weighting modes for `mpdq`:

* **simple** - the default weighting. It only factors in whatever genre weight 
you defined in the instruction file.
* **songs** - this weighting factors in the number of songs you have in each genre 
as well as the genre weight you defined in the instruction file. This will result 
in increased representation from genres you have more songs in.
* **genre** - this weighting uses the genre weight as *the maximum number of songs in that genre to be played per hour*. 
So if you put `Pop=1`, you will *only* hear 1 song from that genre per hour. 
If all genres are (somehow) exhausted in one hour, it will just use the randomly selected genre.

If you do not have mode defined, it defaults to **simple**.

## 6. Usage

`mpdq [-d #][-c /path/to/file][-khe]`

`mpdq` has the following command line switches:

* -c : Which instruction file to use
* -d : Override the default priority in the instruction file
* -k : Kill a currently running `mpdq` process.
* -e : Create an example instruction file at $HOME/.config/mpdq/example_instruction.
* -h : Show a short help message.

`mpdq` will automatically pause if MPD is *not* set to:

* random: off
* repeat: off
* consume: on

So if you want to have "default" behavior back from MPD without interference 
from `mpdq`, but want to leave the process running, just toggle any of those 
values for MPD.

`mpdq` is meant to be run in the background. Because you define the hostname, 
it does *not* have to be on the same machine running MPD.

`mpdq` logs what songs it has played, and will not repeat the same song during 
the time specified in `mpdq.ini`.

### systemd unit

If you wish to use mpdq as a systemd unit, this template works for me (obviously 
change the home directory and user as appropriate, named `mpdq.service`:

```
[Unit]
Description=Start mpdq service
After=mpd.service

[Service]
Type=oneshot
RemainAfterExit=yes
User=steven
Group=steven
ExecStart=/home/steven/apps/mpdq/mpdq -c /home/steven/.config/mpdq/example_instruction_file
ExecStop=/home/steven/apps/mpdq/mpdq -k
WorkingDirectory=/home/steven

[Install]
WantedBy=multi-user.target

```

### Adjusting to changes

If mpdq is running for any length of time, there will be library changes. I 
realized this after adding a bunch of standup albums with the new genre "Standup" 
and suddenly had Steven Wright talking after "Love Will Tear Us Apart".  To 
fix this possible problem, you first have to set `Default=0` in the 
instruction file loaded by systemd.  Then you have to have `mpdq` get restarted 
whenever the MPD database changes.  You can either use `monit` or `fswatch` to 
make this happen.

### Reloading using monit

If you have `mpdq` set up as a systemd unit, reloading it if there's a change 
to the MPD database is pretty easy with this configuration (again, changing 
path names as appropriate:

(The "every 2 cycles" is because of the delay as `mpdq` starts up.)

```
check process mpdq with pidfile /tmp/mpdq.pid
  every 2 cycles
  start program "/bin/systemctl start mpdq.service"
  stop program "/bin/systemctl stop mpdq.service"
  depends on mpd_db


check file mpd_db with path /home/steven/.mpd/tag_cache
   if changed timestamp then restart
```

### using fswatch

If you would rather use the [`fswatch`](https://github.com/emcrisostomo/fswatch) 
utility to achive the same end, have cron call this script at a regular interval:

```
/usr/local/bin/fswatch /home/steven/.mpd/tag_cache | sudo /bin/systemctl stop mpdq.service && sudo /bin/systemctl start mpdq.service
```

## 7. TODO

* reinstate bpm option
* switch instruction file without ending process (perhaps part of the idle loop?)
