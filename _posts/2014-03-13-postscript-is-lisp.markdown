---
layout: post
title: "PostScript is LISP, sort of"
date: 2014-03-13 12:45:00 -07:00
categories: postscript lisp
redirect_from:
- /postscript/lisp/2014/03/13/postscript-is-lisp.html
- /postscript-is-lisp.html
---

I was going doing an exercise from [Thinking in
PostScript](http://wwwcdf.pd.infn.it/localdoc/tips.pdf) and became
confused by this piece of code, from Chapter 5, exercise 3
(pp. 64-65):


    {% highlight postscript %}
    /ushow
    { %def
      LOCAL begin
      % ...
      end
    } dup 0 4 dict put def
    {% endhighlight %}

This code defines a function `ushow`, and uses a local dictionary of
some kind.  But where is `LOCAL` defined?  It's not defined in the
code, and it isn't defined in any Adobe documentation.  And yet this
code ran in Ghostscript.  I ended up [asking on Stack
Overflow](http://stackoverflow.com/q/22385031/238886).  The answer I
got showed me what was really happening, and taught me something I
hadn't quite realized: PostScript has some LISPish qualities to it.

A normal functioin definition in PostScript looks more like this:

    {% highlight postscript %}
    /ushow
    {
    } def
    {% endhighlight %}

(Function definitions often end with `bind def` instead of `def`, but
that doesn't matter here).  Notice the difference?  Not only is that
`LOCAL begin...end` block missing from inside the function definition,
but the end doesn't contain all of that `dup 0 4 dict put` stuff.
_That_ it turns out, is the key to how `LOCAL` works here.  To
understand what's really happening, let's evaluate the puzzling code
as the PostScript interpreter does.  First:

    {% highlight postscript %}
    /ushow
    {% endhighlight %}

And the operand stack is now:

    /ushow

Then comes the start of the procedure:

    {% highlight postscript %}
    {
    {% endhighlight %}

This puts the PostScript in a special mode where it creates an
_executable array_.  From now on until the `}` is parsed, tokens are
not executed, but are simply added to the executable array.  That
means that nothing in the procedure needs to be defined until it
executed.  _That includes `LOCAL`_, so these lines:

    {% highlight postscript %}
      LOCAL begin
      % ...
      end
    {% endhighlight %}

Simply add the symbols `LOCAL`, `begin`, whatever code is elided by
`...`, and `end` to the executable array.  None of it gets executed
until the function is actually called, so it doesn't matter what it is
until then.  It can be giberish, or a mix of giberish and regular
code.  Do you see where this is going?

The end of the executuble array is signalled the `}` at the beginning
of the last line:

    {% highlight postscript %}
    } dup 0 4 dict put def
    {% endhighlight %}

let's take this one operator at a time.  On the right, we'll show
what's on the stack at the completion of that operation:

    {% highlight postscript %}
    }        % /ushow proc
    {% endhighlight %}

This takes the interpreter out of the "defining a procedure" mode and
back into regular, "executing code" mode, then it pushes the procedure
onto the top of the stack.  Now set up some arguments:

    {% highlight postscript %}
    dup      % /ushow proc proc
    0        % /ushow proc proc 0
    {% endhighlight %}

then create a dictionary with room for at least four entries:

    {% highlight postscript %}
    4        % /ushow proc proc 0 4
    dict     % /ushow proc proc 0 dict
    {% endhighlight %}

Finally, here's the fun part:

    {% highlight postscript %}
    put      % /ushow proc
    {% endhighlight %}

`put` stores the dictionary at index 0 of the procedure.  There's a
reason that PostScript calls it an _executable array_.  It really _is_
an array, and it can be manipulated as one.  This code replaced the
symbol `LOCAL` at the beginning of the procedure with a dictionary.
When the procedure executes, `LOCAL` won't be there at all.  In its
place will be a dictionary.

After that excitement, the rest is really boring:

    {% highlight postscript %}
    def      %
    {% endhighlight %}

Finally, store the procedure in the dictionary with the key /ustore.

This is what makes PostScript a little bit like LISP.  In LISP, code
is just _data that you execute_.  A LISP program can manipulate other
code as though it were data (because it is, really): change it, add
things to it, replace it with other code--anything you want.  And so
can you in PostScript.
