---
layout: post
title: "Designing FORTRAN: Setting the Target"
date: 2014-03-07 05:10:00
categories: fortran
---

# Which FORTRAN?

My prior attempts to create a FORTRAN interpreter were targeted to
FORTRAN 66.  I wanted the earliest version of FORTRAN I could find,
which would presumably be for a smaller language, easier to implement
than later versions.  I also wanted a hard specification; not a user
manual, but something targeting compiler writers.  The earliest
FORTRAN specification I could find was for FORTRAN 66.

Now, at the beginning of the third try, I've decided that the better
target is FORTRAN 77.  The biggest reason for this is that the only
specification I can find for FORTRAN 66 is a [scanned, non-OCR
document][fortran-66-spec].  It's not searchable.  And, really, it's
not that great a specification.  The [FORTRAN 77
spec][fortran-77-spec] is a searchable PDF, and pretty well written.

Also, I'm going to need programs to run.  If I limit myself to FORTRAN
66, there will be fewer to choose from.

So, FORTRAN 77 it is.

# Exploiting OOP

When I read the specification, it almost seems as though there was an
object model in the committee's mind.  I think an object model will
pretty much fall out of the spec.  I intend to match the
specification's implied model closely, where practical.  It just seems
easier that way.  It will be easier to reason about the program if its
design matches the specification's implied object model as closely as
possible, even if that means extra objects.

# Be strict on input

A compliant _processor_ (the specification's word for the compiler or
interpreter) must properly run a compliant program, but there are no
requirements for what it must do with a non-compliant program.  It can
do anything it likes, although it probably should not halt and catch
fire.

What I want is for this interpreter to be able to reject _all_
non-conforming programs.  This might not be a good idea, just for the
sheer amount of work involved, but I want it anyhow.  It would be a
nice badge to pin on the project.

## But not always

I imagine, once I start to feed it programs from the real world, I
will find non-compliant programs that exploit some extension or
looseness in the compiler they were written for.  I can imagine it
accepting switches, a la gcc, to allow various extensions or
non-compliant behaviors.

[fortran-66-spec]: http://www.fh-jena.de/~kleine/history/.../ansi-x3dot9-1966-Fortran66.pdf
[fortran-77-spec]: http://www.fh-jena.de/~kleine/history/languages/ansi-x3dot9-1978-Fortran77.pdf
