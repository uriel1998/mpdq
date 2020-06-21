# mpdq

Automatic MPD playlist or party mode creator to provide complexity and 
randomness while autoqueuing MPD without relying on external services.


![mpdq logo](https://raw.githubusercontent.com/uriel1998/mpdq/master/mpdq-open-graph.png "logo")

![mpdq in actino](https://raw.githubusercontent.com/uriel1998/mpdq/master/mpdq.gif "mpdq in action")


## Contents
 1. [About](#1-about)
 2. [License](#2-license)
 3. [Prerequisites](#3-prerequisites)
 4. [Installation](#4-installation)
 5. [Setup](#5-setup)
 6. [Usage](#6-usage)
 7. [TODO](#12-todo)

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

* [mpd]
* [mpc](http://git.musicpd.org/cgit/master/mpc.git/)  
* [shuf]
* [grep](http://en.wikipedia.org/wiki/Grep)  
* [bash](https://www.gnu.org/software/bash/)  

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
```

The last two manage the size of queue that `mpdq` maintains and how many hours 
after playing a song that `mpdq` will *not* play it again.  Defaults are:

```
$HOME/Music
localhost
6600
(no password)
10
8
```

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

## 6. Usage

`mpdq [-d #][-c /path/to/file][-khe]`

`mpdq` has the following command line switches:

* -c : Which instruction file to use
* -d : Override the default priority in the instruction file
* -k : Kill a currently running `mpdq` process.
* -e : Create an example instruction file at $HOME/.config/mpdq/example_instruction.
* -h : Show a short help message.

`mpdq` is meant to be run in the background. Because you define the hostname, 
it does *not* have to be on the same machine running MPD.

`mpdq` logs what songs it has played, and will not repeat the same song during 
the time specified in `mpdq.ini`.

## 7. TODO

* Make the ini look like an ini