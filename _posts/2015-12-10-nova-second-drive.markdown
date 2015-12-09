---
layout: post
title: "Simh/Nova - Mounting a second hard drive"
date: 2015-12-10 00:00:00 -07:00
categories: retrocomputing
---

*This post is part of the series on [Learning the Data General Nova
with simh]({% post_url 2015-12-07-simh-toc %}).*

Let's mount a second hard drive.  First, two ways that don't work, and
then the way that does.

# Let simh make a new file (doesn't work)

From the simh documentation, it seems that you should be able to name
a non-existent file when using simh's _attach_ command, so let's try
that.  First, boot the simulator normally.  Then use ^e (control-e) to
enter the simh prompt:

    R
    ^e
    simh>

The "show" command will show us the disk devices:

    sim> show dkp
    DKP, 4 units
    DKP0, 1247KW, attached to rdos_d31.dsk, write enabled, 4047 (Diablo 31)
    DKP1, 1247KW, not attached, write enabled, autosize
    DKP2, 1247KW, not attached, write enabled, autosize
    DKP3, 1247KW, not attached, write enabled, autosize

The "attach" command will attach the file to the DKP1:

    sim> att dkp1 foo.dsk
    sim> show dkp
    DKP, 4 units
    DKP0, 1247KW, attached to rdos_d31.dsk, write enabled, 4047 (Diablo 31)
    DKP1, 1247KW, attached to foo.dsk, write enabled, 4047 (Diablo 31)
    DKP2, 1247KW, not attached, write enabled, autosize
    DKP3, 1247KW, not attached, write enabled, autosize

This created a zero-size file:

    sim> ! ls -l foo.dsk
    -rw-r--r-- 1 wayne wayne 0 Dec  7 15:56 foo.dsk

(`!` is the simh command to run a shell command.  `ls -l foo.dsk` is
the Linux command to list the file and its attributes.)

Go back to RDOS, and tell it to initialize the drive.  The `/f` switch tells RDOS
to format the drive.

    sim> cont
    
    R
    init dp1/f
    DISK FORMAT ERROR:  DP1
    R

Hmm, that didn't work.

It also doesn't work to make an all-zero file that is the same size as
rdos_d31.dsk.  I tried it.  RDOS, or simh, or both, care about some
data in the file.

# Use a copy of the RDOS disk.

What does work is to make a copy of the RDOS disk and "init" it with
the switch to format the disk.  Escape to simh:

    R
    ^e    
    Simulation stopped, PC: 41737 (STA 3,13)

If there's a disk attached to dkp1, detach it:

    sim> det dkp1

Use a shell command to copy the RDOS disk to the new disk, attach it,
and return to RDOS:

    sim> ! cp rdos_d31.dsk wayne.dsk
    sim> att dkp1 wayne.dsk
    sim> cont

Now initialize the drive with the /f (format) switch:
    
    R
    init/f dp1
    CONFIRM? YES

The DIR command makes that drive the current drive:

    R
    dir dp1

And the list command shows that it is empty:

    R
    list

# References

[RDOS/DOS Command Line Interpreter User's
Manual](http://bitsavers.trailing-edge.com/pdf/dg/software/rdos/093-000109-01_RDOS_Command_Line_Interpreter.pdf)

* p. 3-74 - `DIR` command
* p. 3-77 - `INIT` command
