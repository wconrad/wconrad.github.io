---
layout: post
title: "Configuring SqlServer MAXDOP (Maximum Degree of Parallelism)
date: 2015-12-04 00:00:00
categories: sqlserver
---

Things I want to remember about SqlServer MAXDOP

# sp_AskBrent

[sp_AskBrent][1] is the bees knees.  Microsoft gives you plenty of
statistics--data--about how SqlServer is running.  This tool turns the
data into information, telling you which things are more likely to be
problems that need to be fixed.

sp_askBrent may report that Wait Stats/CXPacket is high.  If it does,
[this page][2] explains what to do about it.

# How to adjust MAXDOP

[This page][3] explains what values you should set MAXDOP to.

[This page][4] has a query you can use to learn how many NUMA nodes
the server has.  The query is:

    SELECT DISTINCT memory_node_id FROM sys.dm_os_memory_clerks

[This page][5] shows how to change the MAXDOP option.  The commands
are:

    EXEC dbo.sp_configure 'show advanced options', 1;
    GO
    RECONFIGURE;
    GO

[1]: http://www.brentozar.com/askbrent/
[2]: http://www.brentozar.com/sql/wait-stats/#CXPACKET
[3]: support.microsoft.com/en-us/kb/2806535
[4]: https://technet.microsoft.com/en-us/library/ms178144(v=sql.105).aspx
[5]: http://shaunjstuart.com/archive/2012/07/changing-sql-servers-maxdop-setting/
