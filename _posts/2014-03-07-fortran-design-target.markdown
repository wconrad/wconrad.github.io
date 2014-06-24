---
layout: post
title: "Designing FORTRAN: Setting the Target"
date: 2014-03-07 05:10:00
categories: fortran
redirect_from: /fortran/2014/03/06/fortran-design-target.html
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

I imagine, once I start to run programs from the real world, I will
find non-compliant programs that exploit some extension or looseness
in the compiler they were written for.  I can imagine the interpreter
needing to accept switches, a la gcc, to allow various extensions or
non-compliant behaviors.

A nice, OOP way to handle this would be to keep particulars of what is
allowed and what is not out of the interpreter proper, and keep them
in "pluggable" strategy objects which the interpreter would use.  For
example, the FORTRAN 77 spec says that identifiers are no longer than
six characters.  Many compilers from the era allowed longer
identifiers, but recognized only so many significant characters of
each identifer--the remaining characters were just noise.

Such a thing in this interpreter might be handled with a strategy
object which validates and returns the significant part of any
identifer.  Here's a strict strategy, adhering to the standard:

    {% highlight ruby %}
    class StrictIdentifierStrategy

      def significant(identifier)
        raise IdentifierTooLong if identifier.length > 6
        identifier
      end

    end
    {% endhighlight %}

Here's a strategy which allows any length identifier, but only the
first so-many characters are significant (many FORTRANs from the era
did this; the number of significant characters was usually fixed for a
given compiler, but varied from compiler to compiler):

    {% highlight ruby %}
    class SubstringIdentifierStrategy

      def initialize(significant_characters)
        @significant_characters = significant_characters
      end

      def significant(identifier)
        identifier[0...significant_characters]
      end

    end
    {% endhighlight %}

When the interpreter starts, the appropriate strategy is picked,
perhaps depending upon a command-line switch:

    {% highlight ruby %}
    @interpreter.identifier_strategy =
      if @args.long_identifiers
        SubstringIdentifierStrategy.new(@args.long_identifiers)
      else
        StrictIdentifierStrategy.new
      end
    end
    {% endhighlight %}

[fortran-66-spec]: http://www.fh-jena.de/~kleine/history/.../ansi-x3dot9-1966-Fortran66.pdf
[fortran-77-spec]: http://www.fh-jena.de/~kleine/history/languages/ansi-x3dot9-1978-Fortran77.pdf
