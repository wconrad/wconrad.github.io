---
layout: post
title: "Some code is hard to unit test"
date: 2014-06-13 05:00:00
categories: fortran ruby testing
redirect_from: /fortran/ruby/testing/2014/06/12/hard-to-unit-test.html
---

I'm bothered that I can't figure out how to write a reasonable unit
test for a reasonable piece of code.

I've been writing unit tests for a long time, long enough that many
unit tests roll off of my fingers pretty easily.  I enjoy getting the
code into a shape where it's both beautiful and easy to unit test, and
for a long time I subscribed to the idea that if the code was hard to
unit test, there was something wrong with it.  I'm not so sure any
more.  It could be that some code that's just fine is still hard to
unit test.

Here's an example of some code that's nasty to unit test, but looks
good to me:

{% highlight ruby %}
# -*- coding: utf-8 -*-

module Fortran77

  class FormatSpecification

    def initialize(edit_descriptors)
      @edit_descriptors = edit_descriptors
    end

    def write(unit, io_list_iterator, format_flags)
      record = unit.new_formatted_record
      @edit_descriptors.error_if_disagrees_with_io_list io_list_iterator
      loop do
        @edit_descriptors.write record, io_list_iterator, format_flags
        break if io_list_iterator.end?
        unit.write_formatted record
        record = unit.new_formatted_record
      end
      unit.write_formatted record
    end

    def to_s
      "(#{@edit_descriptors})"
    end

  end

end
{% endhighlight %}

There isn't a thing wrong with #write that I can see, and yet it'd be
a chore to test.  It interacts with three different objects, calling
five different methods:

* `edit_descriptors.error_if_disagrees_with_io_list`
* `edit_descriptors.write_record`
* `unit.new_formatted_record`
* `unit.write_formatted`
* `io_list_iterator.end?`

The test will spend much effort creating objects (or doubles) to
interact with the test subject.  If the test uses real objects, they
have to be created, and that's not trivial.  If it uses doubles, it
will be a source of friction, fantastically brittle, having an
intimate awareness of internals that are certain to change.

It feels like defeat to not be able to write a reasonable unit test
for this reasonable code.  I think that feeling is wrong, though.
It's not as important that there's a unit test for a piece of code as
it is that there is a test _somewhere_.

So, I think I'm going to let the integration tests cover this one.
It's not that bad: A great deal of [basic101][1] is covered through
integration tests, and that worked out fine.  Integration tests aren't
as fast to run, but they are the only test you can write that are
immune from how the code does it.  They are the ultimate in
resiliancy.

In a program with significant external interactions (database,
network, etc.), integration tests are harder to write, which changes
the math: some unit tests which are hard may become
worthwhile<sup>1</sup>.  But in an interpreter which reads from files
and writes to files, integration tests are as easy as anything.

<sup>1</sup> But see, for example, [hexagonal architecture][2] as a
way of making an application easier to test.

[1]: {% post_url 2014-03-06-basic101 %}
[2]: http://www.duncannisbet.co.uk/hexagonal-architecture-for-testers-part-1
