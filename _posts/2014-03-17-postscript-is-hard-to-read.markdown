---
layout: post
title: "But PostScript is harder to read than LISP"
date: 2014-03-17 14:19:00
categories: fortran
---

There is one significant area where Postscript is worse than LISP.  In
fact, it's worse than any other language I've used in this regard:
It's hard to read.

It all comes from Postscript's minimal syntax and lack of a way to
syntactically group a function's operands.  This syntax requires the
reader, if he has any chance of understand what the code does, to know
the calling sequence of every function he reads.  Let me explain.

Here's some C code that calls a function:

    {% highlight c %}
    i = foo(a, b, 2);
    {% endhighlight %}

What does `foo` do?  We don't know.  But we know immediately that
`foo` takes three arguments and returns one value.

Here's some Ruby code that calls a method:

    {% highlight ruby %}
    foo(1)
    {% endhighlight %}

What does `foo` do?  Again, we don't know.  But we know that foo takes
one argument and returns nothing we care about.

And now some LISP to call a function:

    {% highlight lisp %}
    (foo 1 2)
    {% endhighlight %}

Again, we know right away that foo takes two arguments.

Now, to make my point, let's look at some postscript code:

    {% highlight postscript %}
    1 2 3 4 foo
    {% endhighlight %}

How many arguments does foo take off of the operand stack?  _We can't
tell_.  How many does it push back into the operand stack?  _We can't
tell that, either._ It might consume the 3 and the 4, add them, and
leave a 7 on the stack.  It might consume no operands and leave
nothing on the stack.  Without remembering what `foo` does, you have
no way to know what effect `foo` has upon the stack except by a lucky
guess.  Unfortunately, keeping track of what's on the operand stack is
important when reading postscript.

The author can help you keep track of the operand stack by writing
short functions so you don't have to hold too much in your head at
once, and with the judicious use of the comments.  But that's all work
the author has to do in order to give you something that most other
languages have out of the box.

Postscript is a strange language like that.  It has some fairly
high-level constructs glued together with a syntax that is little more
than a stack-based assembly language.
