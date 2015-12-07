---
layout: post
title: "Simh/Nova - Hello World"
date: 2015-12-07 12:01:00 -07:00
categories: retrocomputing
---

*This post is part of the series on [Learning the DataGenera Nova with
simh]({% post_url 2015-12-07-simh-toc %})*

[simh][1] is a fantastic program that simulates more than a dozen
computers.  Its documentation, although complete, is unfriendly to
someone who has never used it.  What it lacks is something I consider
essential to documentation: The "Hello, world" examples.  A "Hello,
world" example is something that gets you started even if you know
nothing at all about a program.  Without that, you're left with a lot
of details about switches and functions, but no idea how to use them
to do anything.  It's like having a dictionary but not knowing how to
put the words together into a simple sentence.

I'm exploring the [Data General Nova][2] using simh.  This is my
journal of that experience.  I'll document what I learn, including how
to use simh to simulate the Nova.  At least at first, I'll try to keep
the documentation explicit enough and detailed enough that you could
retrace my steps.

# My environment

I run Linux, so any shell commands I provide will need to be changed to work with Windows.

# Install simh

My OS, Debian Linux 8.2 (aka "jessie"), has a package for simh, so I
installed it:

{% highlight bash %}
sudo apt-get install simh
{% endhighlight %}

This installed simh version 3.8.1.

# Download the operating system

On the ["Software Kits" page][3] of the simh web site, you will find a
file titled "RDOS V7.5 for the Nova" and named `rdosswre.tar.Z`.
Download it:

{% highlight bash %}
wget http://simh.trailing-edge.com/kits/rdosswre.tar.Z
{% endhighlight %}

And unpack it:

{% highlight bash %}
tar xzf rdosswre.tar.Z
{% endhighlight %}

This created the directories and files:

* Disks/
* Disks/rdos_d31.dsk
* Licenses/
* Licenses/rdos_license.txt
* Licenses/README.txt

Move the disk image and get rid of the rest:

{% highlight bash %}
mv Disks/rdos_d31.dsk .
rm -rf Disks Licenses
{% endhighlight %}

# Starting simh and RDOS

    wayne@mercury:~/lab/nova$ dgnova
    
    NOVA simulator V3.8-1
    sim> att dkp0 rdos_d31.dsk
    sim> set tti dasher
    sim> boot dkp0
    
    Filename?
    
    NOVA RDOS Rev 7.50
    Date (m/d/y) ? 12/7/2015
    Time (h:m:s) ? 5:23:20

    R

The `R` is RDOS's prompt.  The Nova is booted, runing RDOS, and
awaiting our command.

Yes, you'll need to enter the date and time each time you boot.  The
Nova had no battery powered clock that kept the time while the
computer was off.

simh is quite scriptable, so maybe later I'll see if I can script the
entering of the date and time.

## Simh devices

Simh calls each of the computer's elements a "device," including the
CPU.  Let's use some simh commands to examine devices.  Although our
simulator is running, we can interrupted it and get back to the simh
command prompt by typing ^e (control-e):

    R
    ^e
    Simulation stopped, PC: 41741 (MOVZL# 1,1,SNC)
    sim>

Note: The ^e shown above won't show on your screen.

The simulation is paused and we're at the simh prompt.  Let's list all
of the devices:

    sim> show dev
    NOVA simulator configuration
    
    CPU
    PTR
    PTP
    TTI
    TTO
    TTI1
    TTO1
    RTC, 60Hz
    PLT
    LPT
    DSK
    DKP, 4 units
    MTA, 8 units
    QTY, disabled
    ALM, lines=64

DKP is the controller for the moving head disk controller, which can
control up to four disk drives.  These disk drives do the same thing
as a modern disk drive, although they are far slower, far smaller (in
capacity), far larger (in physical size), and much more expensive.
Oh, and they are removable--the media is in a "pack" that can be
removed.  Otherwise, they are exactly the same as a modern hard drive.
Let's look at that controller:

    sim> show DKP
    DKP, 4 units
    DKP0, 1247KW, attached to rdos_d31.dsk, write enabled, 4047 (Diablo 31)
    DKP1, 1247KW, not attached, write enabled, autosize
    DKP2, 1247KW, not attached, write enabled, autosize
    DKP3, 1247KW, not attached, write enabled, autosize

To get out of the simh prompt and back to the simulation:

    sim> cont

# Displaying the date and time

The `GTOD` command displays the date and time:

    R
    GTOD
    12/07/115   05:43:58

115 is how it display the year "2015".  It's interesting that the OS
handles the year 2015 at all.  After all, RDOS is from the 70's.
Either it's just a lucky accident that the year 2015 works, or it only
appears to work, or someone was thinking 25 years ahead when they
created RDOS.  I prefer to think someone was thinking 25 years ahead.

# Stopping RDOS and existing simh

RDOS should be shut down by unmounting the device that RDOS is mounted
on:

    R
    RELEASE DP0
    
    MASTER DEVICE RELEASED
    
    HALT instruction, PC: 00001 (INC 2,2)
    sim>

To exit simh, use the `quit` command:

    sim> quit
    $

# References

[RDOS/DOS Command Line Interpreter User's
Manual](http://bitsavers.trailing-edge.com/pdf/dg/software/rdos/093-000109-01_RDOS_Command_Line_Interpreter.pdf)

* p. 4-37 - GTOD command
* p. 4-59 - RELEASE command

[1]: https://github.com/simh/simh
[2]: https://en.wikipedia.org/wiki/Data_General_Nova
[3]: http://simh.trailing-edge.com/software.html
