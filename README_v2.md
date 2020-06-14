# mpdq

Automatic MPD playlist or party mode creator to provide complexity and 
randomness while autoqueuing MPD without relying on external services.


![mpdq logo](https://raw.githubusercontent.com/uriel1998/mpdq/master/mpdq-open-graph.png "logo")

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
*Doom Patrol*, and many more.

`mpdq` will autoqueue random tracks from your existing music library, with 
(very) configurable weighting by genre and simple defaults.

If you are looking for the older, heaver, and BPM-using version of `mpdq`, 
those files are in the `bpm_version` directory of this repository.

## 2. License

This project is licensed under the MIT License. For the full license, see `LICENSE`.

## 3. Prerequisites

These are probably already installed or are easily available from your distro on
linux-like distros:  

* [mpd]
* [mpc](http://git.musicpd.org/cgit/master/mpc.git/)  
* shuf
* [grep](http://en.wikipedia.org/wiki/Grep)  
* [bash](https://www.gnu.org/software/bash/)  

## 4. Installation

* Create $HOME/.config/mpdq
* Place mpdq.ini in $HOME/.config/mpdq

This file (example provided) contains only the following lines in 
*this specific order*:

```
/directory/to/music
hostname.of.mpd
6600
password
number of songs to maintain in queue
time (in hours) to not repeat a song
```

## 5. Setup


The behavior of `mpdq` is governed by simple instruction files, as many (or 
few) as you desire.  Each instruction file is a series of lines in the format 
`genre=weight` like so:

```
default=1
rock=3
classical=0
```

Rather than go through all the genres and subgenres of your music library and 
explicitly defining each one, the `default` line assigns a weight to all genres 
not otherwise explictly named. Genres with higher number values will show up 
more often.  In the example above, all genres have a weight of "1" except for 
Rock and Classical.  Rock will show up more often, while Classical will not 
appear at all with a value of "0".

This allows for both very eclectic selections (as with the example above) or 
very focused selections, such as with the example below:

```
default=0
industrial=1
gothic=1
```

## 6. Usage

`mpdq [-d #][-c /path/to/file][-kh]`

`mpdq` has the following command line switches:

* -c : Which instruction file to use
* -d : Override the default priority in the instruction file
* -k : Kill a currently running `mpdq` process.
* -h : Show a short help message.

`mpdq` is meant to be run in the background. Because you define the hostname, 
it does *not* have to be on the same machine running MPD.

`mpdq` logs what songs it has played, and will not repeat the same song during 
the time specified in `mpdq.ini`.

## 7. TODO

* Make the ini look like an ini