---
layout: post
title: "When git goes wrong--Removing files from a commit"
date: 2015-09-01 00:00:00
categories: git
---

# I added too many files to my commit

Suppose you have committed some work:

{% highlight bash %}
$ git add -A .
$ git commit -m'Fix recursion bug'
{% endhighlight %}

But later you look at the commit and discover you have committed
_sekrit_, a file that should not have been committed.

{% highlight bash %}
$ git log --name-status
commit 790af0ed7712c5e47949c1e267793bca54080aeb
Author: Wayne Conrad <wconrad@hsmove.com>
Date:   Wed Sep 2 11:31:04 2015 -0700

    Fix recursion bug

A       somefile.rb
A       sekrit
{% endhighlight %}

*As long as this commit has not been pushed to origin*, you can remove
the file from that commit.  I'll show two different ways to remote the
file.  Which way you pick depends upon whether you want to delete the
file from disk ask well as from the commit, or keep it on disk and
just remove it from the commit.

# To delete the file from disk and from the commit

If you want the file deleted from disk as well as from the commit,
just delete the file and then stage it:

{% highlight bash %}
$ rm sekrit
$ git add sekrit
{% endhighlight %}

Or you could use this git shortcut for "delete a file and stage the
deletion":

{% highlight bash %}
$ git rm sekrit
{% endhighlight %}

Either way, `git status` will show that the file is staged for
deletion:

{% highlight bash %}
$ git status
On branch master
Changes to be committed:
  (use "git reset HEAD <file>..." to unstage)

        deleted:    sekrit
{% endhighlight %}

Now amend the previous comment:

{% highlight bash %}
$ git commit --amend
{% endhighlight %}

The commit will no longer have that file:

{% highlight bash %}
$ git log --name-status -1
commit 55da4e9b07b1337fb8161b9491f864845aad2abb
Author: Wayne Conrad <wconrad@hsmove.com>
Date:   Wed Sep 2 11:31:04 2015 -0700

    Fix recursion bug

A       somefile.rb
{% endhighlight %}

And it is gone from disk:

{% highlight bash %}
$ ls sekrit
ls: cannot access sekrit: No such file or directory
{% endhighlight %}

# To delete the file from the commit but not from disk

To remove that file from the commit but keep it on disk, we'll tell
git to undo the previous commit, but leave all of that commit's
changes on disk.  But first, remember the sha1 of the commit:

{% highlight bash %}
$ git log -1 --oneline
78bcad9 Fix recursion bug
{% endhighlight %}

Having that sha1 will keep us from having to type the commit message
again.  Now, undo the previous commit:

{% highlight bash %}
$ git reset HEAD~
$ git status
On branch master
Untracked files:
  (use "git add <file>..." to include in what will be committed)

        sekrit
        somefile.rb

nothing added to commit but untracked files present (use "git add" to track)
{% endhighlight %}

Now stage the commit again, but this time only add the files that
should be in the commit:

{% highlight bash %}
$ git add somefile.rb
{% endhighlight %}

And finally, commit.  The `-C` switch tells git to use the same commit
message, timestamp, and so on.  It's not necessary to use the -C
switch -- you'd just have to type the commit message again.

{% highlight bash %}
$ git commit -C 78bcad9
[master b36109c] Fix recursion bug
 Date: Wed Sep 2 11:31:04 2015 -0700
  1 file changed, 0 insertions(+), 0 deletions(-)
   create mode 100644 somefile.rb
{% endhighlight %}

The commit no longer has file _sekrit_ in it:

{% highlight bash %}
$ git log --name-status  -1
commit b36109cf76020f365050a33d374dc15b386050d0
Author: Wayne Conrad <wconrad@hsmove.com>
Date:   Wed Sep 2 11:31:04 2015 -0700

    Fix recursion bug

A       somefile.rb
{% endhighlight %}

But the file is on disk:

{% highlight bash %}
$ git status
On branch master
Untracked files:
  (use "git add <file>..." to include in what will be committed)

        sekrit

nothing added to commit but untracked files present (use "git add" to track)
{% endhighlight %}

# How to keep git from committing that file ever again

If the file should never be committed to git, add it to the
`.gitignore` file:

{% highlight bash %}
$ echo 'sekrit' >>.gitignore
$ git add .gitignore
$ git commit -m'Ignore sekrit'
[master 15336c9] Ignore sekrit
 1 file changed, 1 insertion(+)
{% endhighlight %}

Git will no longer consider the file untracked:

{% highlight bash %}
$ git status
On branch master
nothing to commit, working directory clean
{% endhighlight %}
