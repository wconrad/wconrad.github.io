---
layout: post
title: "Simh/Nova - Scripting Startup"
date: 2015-12-09 00:00:00 -07:00
categories: retrocomputing
---

*This post is part of the series on [Learning the Data General Nova
with simh]({% post_url 2015-12-07-simh-toc %}).*

In order to start simh with RDOS, we need to enter the same series of
commands every time:

    $ dgnova

    NOVA simulator V3.8-1
    sim> att dkp0 rdos_d31.dsk
    sim> set tti dasher
    sim> boot dkp0
    
    NOVA simulator V3.8-1

We can put those commands into a file so that we don't have to type
them.  Create a file boot.simh with the simh commands:

    att dkp0 rdos_d31.dsk
    set tti dasher
    boot dkp0

If we pass the name of that file to simh, it will run the commands
from that file:

    $ dgnova boot.simh
    
    NOVA simulator V3.8-1

But I don't want to type even that much.  Let's create the file
boot.sh:

    #!/bin/sh
    dgnova boot.simh

Mark it as executable:

    chmod +x boot.sh

And now start the sim with it:

    $ ./boot.sh
    
    NOVA simulator V3.8-1
