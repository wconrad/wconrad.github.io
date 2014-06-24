---
layout: post
title: "Fortran, take IV"
date: 2014-06-01 15:00:00
categories: ruby fortran
redirect_from:
- /ruby/fortran/2014/06/01/fortran-take-4.html
- /fortran-take-4.html
---

I've failed to make a Fortran interpreter, written in Ruby, three
times now.

_Take 1_ used the Treetop parser.  It's a great parser, but I could
not figure out how to generate a parse tree.  So I went looking for
another [PEG](http://en.wikipedia.org/wiki/Parsing_expression_grammar)
for Ruby, and found Parslet.  So, on to:

_Take 2_, using the Parslet parser.  This parser seems much nicer than
Treetop, but again, the generation of the parse tree was too
difficult.  I just wasn't "getting it."  I decided to take a break
from Fortran and write a Basic interpreter, in order to learn Parslet
using a simpler language.  Having finished that, I went back to
Fortran with renewed confidence.  So, on to:

[_Take 3_]({% post_url 2014-03-06-starting-fortran %}), against using the Parslet parser.  At which I failed, again,
when it came to generating the parse tree.  I just don't seem to be
able to wrap my head around the mechanics of building a parse tree in
Parslet.  Among other things, left associative operators are a pain in
Parslet (and, if I had to guess, in any PEG).  I pretty much gave up
on Fortran after take 3.

Then, I decided to write tutorial on how [recursive descent
compilers](http://en.wikipedia.org/wiki/Recursive_descent_parser) can
be constructed in Ruby.  A recursive descent compiler is insanely easy
to write.  There are a few reasons they're not used much for serious
work; the most important being that a recursive descent compiler is
only efficent and easy when used to parse a context free grammar.
Fortran, for example, is not context free.

Partway through that tutorial I realized that it would take only a few
lines of code to allow arbitrary backtracking.  With backtracking, a
recursive descent compiler can parse languages such as Fortran.  So,
with the tutorial still unpublished, I'm on to:

_Take 4_, using a
hand-rolled recursive descent compiler with backtracking.

Finally, I'm getting some traction.  For the first time, I've got an
interpreter that can execute some simple Fortran statements, such as:

{% highlight fortran %}
      A = (1.0 + 2) / 3 ** (-4)
      PRINT *, 'A =', A
{% endhighlight %}


The interpreter has:

* PRINT statement with list directed output
* INTEGER constants
* REAL constants
* LOGICAL constants
* Simple variables
* Math operators (`+`, `*`, etc.)
* Logical operators (`.AND.`, `.OR.`, etc.)
* Comparison operators (`.LE.`, `.EQ.`, etc.)
* Implicit type casting

It's not a lot, and much of it is not spec compliant, or is
incomplete, but it's a good start.  The framework for the type system
has been laid down, and it look much cleaner than it did in basic101.
The lesson from basic101 is to keep a very clear distinction between
Ruby types such as Integer, Float and String, and language types such
as INTEGER, REAL, and CHARACTER.  The two type systems should only be
allowed to interact at clearly defined boundaries.  I sort of stumbled
into that in basic101, so it's a bit messy there, but it's clean here.

It remains to be seen whether the recursive descent compiler with
backtracking is going to fly--Wikipedia warns that there could be
trouble ahead, such as possibly requiring exponential time.  But,
forging ahead...
