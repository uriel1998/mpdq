MPDQ
========

Automatic MPD playlist creator to provide a bit of complexity and 
randomness while autoqueuing MPD, but without relying on external 
services like last.fm. Written in BASH so that if it doesn't quite meet 
your needs and to make it a bit easier to prevent having bitrot.

## Requires

* [mpc](http://git.musicpd.org/cgit/master/mpc.git/)  
* [ffmpeg](https://www.ffmpeg.org/)
* [zenity](https://github.com/GNOME/zenity)

## Setup

### Tag Music Files

* Make sure your music is properly tagged with the genre and that the 
BPM values are set. You might find my [bpmhelper](https://github.com/uriel1998/yolo-mpd#bpmhelpersh) 
script of use with the latter.

### Configuration Files

* Create $HOME/.config/mpdq
* Place mpdq.rc in $HOME/.config/mpdq

This file (example provided) contains only the following lines in 
*this specific order*:

```
/directory/to/music
hostname.of.mpd
6600
password
number of songs to maintain in queue
range for bpm
time (in hours) to avoid repeating song
```

The bpm range is *not* a percentage; rather it's a set number. So for 
example, if the currently playing song has a bpm of 130, a value of "10" 
there will provide matches of songs with a bpm range from 120 to 140.

### Setup Commands

There are three setup switches: -s, -g, and -f.  

* -f: This switch runs both -s and -g
* -g: Genre matching. The program will present you with lists of your 
genres, using Zenity, and you can pick which genres "go" with other 
genres. For example, you might determine that "Acoustic" goes with 
"Singer/Songwriter" and "Folk" and "Celtic". If a genre has already been
matched, you are *not* presented it again. This information is stored 
in plaintext in $HOME/.config/mpdq/genredefs.rc .
* -s: Song scanning. Because MPD does not store BPM values in its 
database, this switch tells the program to scan every song file in your 
main MPD directory (using the ffprobe function from ffmpeg) and writes
the information we need to $HOME/.config/mpdq/songdefs.rc . It will not
rescan files it has information for, so while the first scan will take a
**LONG** time, further scans should go more quickly.

## Usage

Run `mpdq` without any arguments.  It will loop with MPD's event update 
cycle.


### Startup Things The Program Does
* On startup, it deletes old entries in the logfile of songs that it has 
played (located at $HOME/.config/mpdq/playedsongs.log). It does this task 
approximately every hour of continuous operation. 
* This program turns on consume mode and starts MPD when it begins.
* If there is an empty playlist on program start, it randomly picks a 
song and starts playing it. 
* Best practice is to start playing a song in MPD before starting this 
program.

### Operation
The program first looks at the *initial* playing song. If there are 
matching genres already configured, it picks one of those genres 
randomly. From that set, it narrows it to songs within the defined BPM 
range. And then it checks to make sure it's not been played within the 
user defined length of time.

If the first match doesn't work, it tries again with a slightly wider 
range of BPM values. It repeats this up to ten times, and if it still 
cannot find a match, it will try to find a song within the original BPM 
range in *any* genre.

Rinse and repeat.

There is one runtime switch: -j . It means the matches are to the *currently* 
playing song. This can provide more diversity, but also means that the 
genre can jump or drift. For example, if *Pop* matches to *Dance* which 
matches to *Electronic* which matches to *Darkwave* which matches to 
*Industrial*... you're waaaaay away from Cyndi Lauper awfully fast.

# TODO

* Progress indicator for song scanning
* Way to (easily) indicate that some genres are "better" matches than others
* Ways to blacklist some songs or genres


Playlistmaker
========

This is created so that you can create static playlists based on "smart" 
criteria like combinations of *genre* and *bpm*.  (See `recentsongs.sh` for
a way to create a playlist of songs recently added to your system.)

This utility *only* works in combination with the mpdq database, so you
have to run `mpdq -s` at the very least so that it can scan your music files.

It's pretty self-explanatory - it creates playlists with a default of the 
current date and time in $HOME/.mpd/playlists, though you can choose the 
location.  Then you can select as many genres as you want, the BPM you 
want as the centerpoint, and the range you want (in percentage).  It'll 
spit out a playlist you can then easily play in MPD.
