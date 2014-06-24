---
layout: post
title: "Parsing Fortran's Hollerith constant with Rattler"
date: 2014-06-21 04:30:00
categories: ruby parsing-expression-grammars fortran
redirect_from:
- /ruby/parsing-expression-grammars/fortran/2014/06/20/parsing-hollerith-constant-with-rattler.html
- /parsing-hollerith-constant-with-rattler.html
---

# The problem

[I recent wondered][1] whether Rattler could parse something as nasty
as Fortran's Hollerith constant.  It turns out, it can, quite
easily.

A hollerith constant is a crazy way of specifying a string literal
which includes the length of the string.  For example, here's a Hollerith constant for the string "HELLO"

{% highlight fortran %}
      5HHELLO
{% endhighlight %}

It breaks down like this:

* "5" - There are five characters in this...
* "H" - ... Hollerith constant
* "HELLO" - And they are "HELLO"

If you were trying to design a syntax to befuddle parsers, that'd be
it.

# The solution

Here's a parser demonstrating the technique:

{% highlight ruby %}
#!/usr/bin/env ruby

require "rattler"

class Hollerith < Rattler::Runtime::ExtendedPackratParser
  grammar %{
    hollerith <- ~(integer ~{count = _} "H") @(. &{(count -= 1) >= 0} )+
    integer <- @(DIGIT+) { _.to_i }
  }
end

p Hollerith.parse!("5HHello...")     # "Hello"
{% endhighlight %}

The input string contains the suffix "...", which we can see was not
included in the result.  It stopped after five characters, just as it
should.

# How it works

Let's break down the definition of _hollerith_.

    hollerith <-
      ~(                            # Don't include this group in the parse tree
        integer ~{count = _}        # parse an integer, then set variable
                                    #   count to that integer
        "H"                         # Parse an "H"
      )
      @(                            # Include this group in the parse tree
                                    #   as a single string
        .                           # parse any character
        &{(count -= 1) >= 0}        # Decrement count.  Succeed until
                                    #   it goes negative.
      )+                            # Repeat one or more times

Rattler has passed my acid test for parsers with elegance and ease.  I
think the next thing to do is to convert the Fortran interpreter from
my hand-rolled parser to Rattler and see how it holds up under fire.

[1]: {% post_url 2014-06-19-rattler %}
