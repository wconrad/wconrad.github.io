---
layout: post
title: "Concatenating Enumerator"
date: 2014-06-03 15:00:00
categories: ruby fortran
redirect_from:
- /ruby/fortran/2014/06/03/concatenating-enumerator.html
- /concatenating-enumerator.html
---

First I'm going to complain/brag about how complex Fortran can be, and
then I'm going to show a neat bit of Ruby code that I'm using to help
tame that complexity.  If you don't care that much about ancient
computer languages, just scroll down to the bottom for the Ruby code.

# Fortran formatted I/O: It's complicated!

In my Fortran interpreter,
I'm taking a stab at Fortran's somewhat intimidating format statement.
The format statement is a DSL for formatted I/O, and it is awash in
features.  I'll show some examples.  Don't try too hard to understand
them--this isn't mean to be a tutorial, so I'm going to gloss over a
_lot_.  Just bask in the complexity.

Here's a simple example writing an integer, a float ("real"
in Fortran parlance<sup>1</sup>), 

{% highlight fortran %}
      WRITE (*, 10) 1, 2.345, 'FOO'
10    FORMAT (I4, F7.2, A4)
{% endhighlight %}

You can read the format statement as "an integer, printed using 4
columns; a float (sorry, "real") using 7 characters, 2 of which are
for the fractional part, and a "character" (the Fortran name for a
string <sup>2</sup> ).

This writes:

       1    2.35 FOO

That's not too complex, but just wait.  Let's have a little bit of
automatic repetition:

{% highlight fortran %}
      WRITE (*, 10) 1, 2, 3, 4, 5
10    FORMAT (I2, I2)
{% endhighlight %}

There are five items being written, but only two format specifiers
(`I2, I2`).  No problem, Fortran's got your back.  It will simply
repeat the entire format specifier, writing two integers on each line,
except for the last line, which only gets one integer:

    1 2
    3 4
    5

You can repeat things by preceding a format specifier with a number,
and you can order the end of a record with a slash:

{% highlight fortran %}
      WRITE (*, 10) 1, 2, 3, 4, 5, 6
10    FORMAT (2I2 / I2)
{% endhighlight %}

which writes:

    1 2
    3
    4 5
    6

Oh, and did I mention the famous "implied do loop?"  Your I/O
statement can have a loop built in.  This is often used to write
arrays:

{% highlight fortran %}
      WRITE (6, 10) ((A(I,J), J=1,10), I=1,10,2)
 10   FORMAT(1X, 10F10.4)
{% endhighlight %}

This outputs the elements of an array in a specific order.  In Ruby,
it would look something like this:

{% highlight ruby %}
(1..10).step(2).each do |i|
  (1..10).each do |j|
    print "10.4f" % a[i][j]
  end
  puts
end
{% endhighlight %}

That's just the beginning.  So how do we go about taming it?

# The problem

The problem is that Formatted I/O is a dance between two entities: The
list of values specified in the WRITE statement, and the FORMAT
statement that tells how the elements are formatted.  Through all of
this, it's actually the format statement that is in control.  It pulls
data from the write statement, essentially.

Naively, the write statement could gather up all the values in the I/O
list (the list of values to format) into a single array and pass them
to the format statement, something like this:

{% highlight ruby %}
    values = io_list.flat_map(&:values)
    format.apply_values values
{% endhighlight %}

The format statement could then shift values off of the `values` array
as needed.  This would work, but it's not optimal: an I/O list can be
big: A single name such as "A" can represent an immense array.  We
don't want to gather up all those values into a big array, and we
don't need to.

# The solution

Instead, what's wanted is to use external enumerators:

{% highlight ruby %}
    enums = io_list.map(&:to_enum)
    format.apply_values enums
{% endhighlight %}

Instead of passing values to the format statement, we pass enumerators
which, when iterated over, return values.  The format statement then
pulls values off of the enumerators, one by one, until there are no
values left.

Scalars such as integers and floats (sorry, "reals") have enumerators
that only yield a single value.  Fortran arrays have enumerators that
yield every value in the array.  Implied do's also have enumerators
that yield multiple values.

It's a good plan, but asking the format statement to deal with
multiple enumerators seems awkward.  In order to get the next value,
it will have to get one from the next enumerator, and if that fails,
move on to the next enumerator.  It's not a _huge_ burden, but those
little annoyances add up.  So what if we could get multiple
enumerators from the I/O list, but then turn them into a single
enumerator to pass to the format statement?:

{% highlight ruby %}
    enums = io_list.map(&:to_enum)
    enum = ConcatenatingEnumerator.new(enums)
    format.apply_values enum
{% endhighlight %}

Now all we need is a ConcatenatingEnumerator.  That, it turns out, is
very simple:

{% highlight ruby %}
class ConcatenatingEnumerator < Enumerator
  def initialize(enumerators = [])
    super() do |yielder|
      enumerators.each do |enumerator|
        enumerator.each do |item|
          yielder.yield item
        end
      end
    end
  end
end
{% endhighlight %}

and a simple demonstration of its use:

{% highlight ruby %}
enum1 = [1, 2, 3].to_enum
enum2 = [4, 5].to_enum
enum = ConcatenatingEnumerator.new([enum1, enum2])
p enum.to_a    #=> [1, 2, 3, 4, 5]
{% endhighlight %}

**2015-03-11** - In [More Concatenating Enumerator][1], there's a minor
enhancement to ConcatenatingEnumerator, and another example of how it
is used.

**2015-07-23**: Someone on the Ruby forum [asked if enumerators could
be joined][2].  An [issue was created asking for the feature][3], but
was rejected.

[1]: {% post_url 2015-03-10-more-concatenating-enumerator %}
[2]: https://www.ruby-forum.com/topic/1965489
[3]: https://redmine.ruby-lang.org/issues/709

-----

**Footnotes**

<sup>1</sup> The designers of Fortran had not yet caught on that floating point
numbers are a pretty miserable subset of real numbers.

<sup>2</sup> Yes, the data type we now call "string," Fortran called
"character."  That makes naming some of the variables in a Fortran
interpreter _really_ awkward.
