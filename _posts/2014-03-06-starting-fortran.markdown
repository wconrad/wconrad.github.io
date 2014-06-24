---
layout: post
title: "Next Project: FORTRAN"
date: 2014-03-07 04:23:00
categories: fortran
redirect_from: /fortran/2014/03/06/starting-fortran.html
---

Now that I'm done with [basic101][basic101], the next program I want
to tackle is a FORTRAN interpreter.  I've already tried this twice;
this will be my third try.

# Take one - FORTRAN with treetop

The first try used the [treetop](http://treetop.rubyforge.org/)
parser, but I never could figure out how to cleanly turn the treetop
parse tree into an abstract syntax tree.  Unfortunately, I implemented
much of the parser before I tried writing the transform, so a lot of
work was wasted when I abandoned treetop.

I had successfully used treetop for a parser at work, to parse an HTML
markup language used by a proprietary PostScript generator.  That was
pretty simple, since no transform needed to use the result of any
other transform.  It was a simple matter of walking the parse tree
depth first, gathering up transforms, and throwing away any parse node
that didn't generate a transform.  But the transforms of a language
need to refer to each other: This _multiply_ node needs references to
its two _term_ nodes, and so on.  I couldn't figure out how to get
treetop to do that.

It's not treetop's fault.  I'm just a bit dense.

# Take two - FORTRAN with Parslet

The second try at FORTRAN used [Parslet][parslet] instead of treetop, but I
didn't really understand Parslet's transform rules.  In frustration, I
stopped this project, too.  I didn't get very deep into it, so it
wasn't much of a loss.

# Take two-and-a-half: basic101 with Parslet

I then decided to write basic101 in order to learn Parslet more
thoroughly, with a simpler language, so that I could spend more of my
time learning the mechanics of parsing and transforming, and less time
worrying about the language.  FORTRAN is a formidible language.

I remembered the pain of my first try at Fortran, where I plowed all
that work into the parser for nothing, so when I wrote basic101, the
first thing I did was an entire slice of the language, enough to parse
and run a simple `REM` statement.  After that, `PRINT 1`.  I wanted to
prove that Parslet, and my general approach to the interpreter, was
viable _before_ I sunk a bunch of work into it.

There are two things about Parslet that I didn't understand at the
start of basic101:

1. A transform rule must match _an entire hash at once_.
2. Left-associative operators need special techniques to handle, lest
   you cause the parser to loop infinitely.

Writing basic101 taught me the first thing pretty well: I could stand
in front of a white board and explain it to someone.  The second, I
can't.  I can muddle through it, but not adeptly.

# Take three: FORTRAN with Parslet, again

So here we are.  I think I can bend Parslet to my will (or me to its)
well enough now to handle FORTRAN.  It's time for FORTRAN, take three.

[basic101]: http://www.github.com/wconrad/basic101
[parslet]: http://kschiess.github.io/parslet/
