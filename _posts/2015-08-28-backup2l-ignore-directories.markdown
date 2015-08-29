---
layout: post
title: "A trick to make backup2l ignore certain directories"
date: 2015-08-28 00:00:00
categories: linux
---

My main drive's RAID configuration protects me against drive failures,
but it doesn't protect me against accidentally deleting a file.  For
that, I use the [backup2l][1] program to periodically backup my files
to a third hard drive.

backup2l has a fairly easy way to ignore a file or directory: If the
name of its path includes ".nobackup" anywhere in it, then that file
or directory won't be backed up.  However, it's ugly to have to look
at ".nobackup" in directory names.  Also, some directories that you
don't want to back up can't be renamed.  For example, your virtual
machine manager may keep virtual images, which are very large, in a
directory that it expects to have a certain name.  You can't just
rename the directory to end in ".nobackup", or the virtual machine
manager won't be able to find the images.

The workaround is simple.  Go ahead and rename the directory to
include ".nobackup".  Also, start it with a "." so it will be hidden:

    mv my_big_directory .my_big_directory.nobackup

Now create a symlink to the directory so it can be referenced with its
original name:

    ln -s .my_big_directory.nobackup my_big_directory

You will see the symlink when you use "ls -l":

    lrwxrwxrwx 1 wayne wayne   24 Aug 28 10:02 my_big_directory -> .my_big_directory.nobackup

but otherwise the directory will function the same as it did
before--except that it won't be backed up by backup2l.

[1]: http://backup2l.sourceforge.net/
