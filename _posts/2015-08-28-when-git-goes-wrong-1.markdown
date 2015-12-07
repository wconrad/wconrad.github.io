---
layout: post
title: "When git goes wrong--Adding files to a commit"
date: 2015-08-28 12:00:00 -07:00
categories: git
---

[git][1] is more than a backup mechanism.  It's a way to communicate
with other programmers and with your future self.  In order for this
communication to be clear, it's important to keep your git commits
clean.  A commit is cleanest when it does one thing, has passing
tests, and has a good description.

We're going to explore how to create good git commits when you start
out with bad ones.  It's pretty common to accidentally commit the
wrong thing, or forget to commit a file, but git makes it easy to fix
a previous commit.  But first, this important warning:

**IMPORTANT WARNING**

Once you have pushed a commit to a remote server that other
programmers can pull from, you shouldn't change it.  You can change
it--it's not difficult, but you can really mess up life for those
other programmers if you don't know what you're doing.  Until then,
don't attempt to rewrite a commit that's already been pushed to a
remote server.

However, _before_ you've pushed any commits upstream to origin, you
can change them around all you want.  Let's learn how.

# I forgot to add some files to my commit

Suppose you have made changes to a few files:

{% highlight bash %}
$ git status
On branch master
Changes not staged for commit:
(use "git add <file>..." to update what will be committed)
(use "git checkout -- <file>..." to discard changes in working directory)

modified:   bar
modified:   foo

no changes added to commit (use "git add" and/or "git commit -a")
{% endhighlight %}

And you create a commit with one of the files, accidentally leaving
the other file out:

{% highlight bash %}
$ git add bar
$ git commit -m'Fixed issue #1'
[master 12bf5d9] Fixed issue #1
1 file changed, 1 insertion(+)
{% endhighlight %}

Then, when doing a `git status`, you notice that a file was not
committed:

{% highlight bash %}
$ git status
On branch master
Changes not staged for commit:
(use "git add <file>..." to update what will be committed)
(use "git checkout -- <file>..." to discard changes in working directory)

modified:   foo

no changes added to commit (use "git add" and/or "git commit -a")
{% endhighlight %}

You confirm that by using `git log` to look at the most recent commit:

{% highlight bash %}
$ git log --name-status -1
commit 12bf5d90ac19826320efabb20972e48ce4207844
Author: Wayne Conrad <wconrad@hsmove.com>
Date:   Fri Aug 28 11:36:15 2015 -0700

    Fixed issue #1

M       bar
{% endhighlight %}

# The wrong way to fix it

You could just make another commit with the missing files:

    # Please don't do this
    $ git add bar
    $ git commit -m'Adding missing file from fix for issue #1'

And, if you have already pushed the previous commit to origin, this is
what you'll have to do.  But when you have a choice, please don't do
this.  You want the commit's _idea_ to be represented in a single
commit, not in two.  Also, it's unlikely that the first of the two
commits would have passing tests.

# So let's fix it

To the file you left out to the commit, you can first stage the file
using `git add`:

{% highlight bash %}
$ git add foo
{% endhighlight %}

and then add the staged files to the _previous_ commit by using the
`git commit` with the `--amend` switch:

{% highlight bash %}
$ git add foo
$ git commit --amend
{% endhighlight %}

This will bring up an editor window which you can use to edit the
commit message, if desired:

    Fixed issue #1
    
    # Please enter the commit message for your changes. Lines starting
    # with '#' will be ignored, and an empty message aborts the commit.
    #
    # Date:      Fri Aug 28 11:36:15 2015 -0700
    #
    # On branch master
    # Changes to be committed:
    #       modified:   bar
    #       modified:   foo
    #

After you save the file, git will ammend the commit, adding the file
that you accidentally left out.    

{% highlight bash %}
$ git log -1 --name-status
commit 75b7e96d876e5fb4909469d26019d766b7189ae2
Author: Wayne Conrad <wconrad@hsmove.com>
Date:   Fri Aug 28 11:36:15 2015 -0700

    Fixed issue #1

M       bar
M       foo
{% endhighlight %}

Git means never having to say you're sorry.

[1]: https://git-scm.com/
