---
layout: post
title: "Simh/Nova - Recovering from a Bad Shutdown"
date: 2015-12-07 12:02:00 -07:00
categories: retrocomputing
---

*This post is part of the series on [Learning the DataGenera Nova with
simh]({% post_url 2015-12-07-simh-toc %})*

RDOS keeps an open count for each file.  That's not unusual.  What is
unusual is that it keeps that count on disk.  I'm not sure why.  Can
two Nova CPUs can access the same physical disk concurrently?  That
would be one reason to keep use counts on disk.

# Use counts after a normal start

Let's start the simulation as above, and then use the LIST command to
see some files:

    R
    list/e
    ...
    BACKUP.             978  D       05/30/85 21:05  05/31/85  [005011]     0
    CLI.S0                0  D       12/07/115 11:45 12/07/115 [005015]     1
    CLI.SV            11264  SD      05/02/85 20:05  05/31/85  [000206]     0
    OVLDR.SV           7168  SD      05/02/85 21:33  05/31/85  [001316]     0
    CLI.ER             3584  D       05/02/85 20:05  12/07/115 [000377]     1
    ASM.SV            10240  SD      05/01/85 18:59  05/31/85  [001647]     0
    ENPAT.SV           3584  SD      05/02/85 21:35  05/31/85  [002053]     0
    NSID.SR             793  D       10/20/83 20:44  05/31/85  [002165]     0
    CLI.OL            50176  C       05/02/85 20:05  12/07/115 [000235]     1
    MCABOOT.SV         5120  SD      05/08/85 10:28  05/31/85  [001127]     0
    ...

I gave the command as `list/e`, but it could have been given as `LIST/E`
just as well.  RDOS is case insensitive.

The `/E` switch tells RDOS to list the dates and use counts for each
file.  The last number on each line is the file's use count.

# Shut down improperly

Get the simh prompt using ^e, and then exit simh.  This will
simulation pulling the plug on the Nova:

    R
    ^e
    Simulation stopped, PC: 41741 (MOVZL# 1,1,SNC)
    sim> quit
    Goodbye

Now start simh/nova.  During boot, RDOS will give you a warning
indicating that there are non-zero use counts:

    NOVA simulator V3.8-1
    
    Filename?
    
    
    Partition in use - Type C to continue
    continue
    
    NOVA RDOS Rev 7.50
    Date (m/d/y) ? 12/7/2015
    Time (h:m:s) ? 12:24:24
    
    R

Let's see the counts

    R
    list/e
    ...
    OVLDR.SV           7168  SD      05/02/85 21:33  05/31/85  [001316]     0
    CLI.ER             3584  D       05/02/85 20:05  12/07/115 [000377]     2
    ASM.SV            10240  SD      05/01/85 18:59  05/31/85  [001647]     0
    ENPAT.SV           3584  SD      05/02/85 21:35  05/31/85  [002053]     0
    NSID.SR             793  D       10/20/83 20:44  05/31/85  [002165]     0
    CLI.OL            50176  C       05/02/85 20:05  12/07/115 [000235]     2
    MCABOOT.SV         5120  SD      05/08/85 10:28  05/31/85  [001127]     0
    ...

No use count should be greater than 1 right now, so things are not
right.

# Clearning use counts

Let's use the `CLEAR` command to clear the use counts:

    R
    clear/a/d/v
    CLEARED $TTI.
    CLEARED $PTP.
    CLEARED $PTR.
    CLEARED $TTO.
    CLEARED $TTP.
    CLEARED $TTR.
    CLEARED $LPT.
    CLEARED SYS.DR

`clear/a/d/v` clears most files, but not all of them.  Most notably:

    R
    list/e cli.-
    CLI.S0                0  D       12/07/115 12:25 12/07/115 [005015]     1
    CLI.SV            11264  SD      05/02/85 20:05  05/31/85  [000206]     0
    CLI.ER             3584  D       05/02/85 20:05  12/07/115 [000377]     2
    CLI.OL            50176  C       05/02/85 20:05  12/07/115 [000235]     2
    CLI.CM              131  D       12/14/95 16:20  12/14/95  [005055]     0

We have to name these files explicitly to clear their use counts:
    
    R
    CLEAR/V CLI.S0 CLI.ER CLI.OL
    CLEARED CLI.S0
    CLEARED CLI.ER
    CLEARED CLI.OL
    R
    list/e cli.-
    CLI.S0                0  D       12/07/115 12:25 12/07/115 [005015]     0
    CLI.SV            11264  SD      05/02/85 20:05  05/31/85  [000206]     0
    CLI.ER             3584  D       05/02/85 20:05  12/07/115 [000377]     0
    CLI.OL            50176  C       05/02/85 20:05  12/07/115 [000235]     0
    CLI.CM              131  D       12/14/95 16:20  12/14/95  [005055]     0

The use counts have been reset, but they are now wrong: Some of the
files we've cleared the use count on are actually in use (certain of
the CLI.- files).  The use count is used to prevent modification or
deletion of a file that is in use, so as long as we leave those alone,
it seems to me that there should be no harm in leaving their use
counts incorrect set to 0.  I don't know for sure.

# Normal shutdown and restart

A normal shutdown and reboot would return the counts to their normal
values, so let's try it:

    release dp0
    
    MASTER DEVICE RELEASED

We then exit simh and reboot (not shown), and see:
    
    NOVA simulator V3.8-1
    
    Filename?
    
    
    NOVA RDOS Rev 7.50
    Date (m/d/y) ? 12/7/2015
    Time (h:m:s) ? 12:47:40
    
    R

There was no "PARTITION" warning, which is good.  Let's check those
use counts:

    R
    LIST CLI.ER CLI
    ...
    OVLDR.SV           7168  SD      05/02/85 21:33  05/31/85  [001316]     0
    CLI.ER             3584  D       05/02/85 20:05  12/07/115 [000377]     1
    ASM.SV            10240  SD      05/01/85 18:59  05/31/85  [001647]     0
    ENPAT.SV           3584  SD      05/02/85 21:35  05/31/85  [002053]     0
    NSID.SR             793  D       10/20/83 20:44  05/31/85  [002165]     0
    CLI.OL            50176  C       05/02/85 20:05  12/07/115 [000235]     1
    MCABOOT.SV         5120  SD      05/08/85 10:28  05/31/85  [001127]     0
    ...

*Note*: The clear command will need to be issued on every partition
and directory that was "initialized" (mounted) at the time the system
was improperly shut down.  We didn't have any directories initialized,
so didn't need to do that.

# References

[RDOS/DOS Command Line Interpreter User's
Manual](http://bitsavers.trailing-edge.com/pdf/dg/software/rdos/093-000109-01_RDOS_Command_Line_Interpreter.pdf)

* p. 4-17 - `CLEAR` command
* p. 4-42 - `LIST` command

[1]: http://bitsavers.trailing-edge.com/pdf/dg/software/rdos/093-000109-00_RDOS_CLI_Feb75.pdf


[1]: https://github.com/simh/simh
[2]: https://en.wikipedia.org/wiki/Data_General_Nova
[3]: http://simh.trailing-edge.com/software.html
