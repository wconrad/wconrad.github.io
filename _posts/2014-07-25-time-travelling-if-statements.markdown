---
layout: post
title: "Dynamic dispatch is time travel for if statements"
date: 2014-07-25 13:00:00
categories: ruby oop
---

_Dynamic dispatch is how conditional logic travels backwards in time_

# What is dynamic dispatch?

[Dynamic dispatch](http://en.wikipedia.org/wiki/Dynamic_dispatch) is
when your language decides at run time which actual method to call.
For example:

{% highlight ruby %}
class Foo
  def say
    puts "foo"
  end
end

class Bar < Foo
  def say
    puts "bar"
  end
end

def make_noise(o)
  o.say
end

make_noise(Foo.new)    # => "foo"
make_noise(Bar.new)    # => "bar"
{% endhighlight %}

On encoutering `o.say`, Ruby decides _at runtime_, based on o's type,
whether to call `Foo#say` or `Bar#say`.  That's all dynamic dispatch
is.  I remember it being a big deal to C programmers when they first
saw C++, but it's pretty routine now.

# Logging without time travel

Let's have an object that needs to do some logging, or not.

{% highlight ruby %}
class Foo

  def initialize(verbose)
    @verbose = verbose
  end

  def bar
    print "bar starting..." if @verbose
    # ...
    puts " done" if @verbose
  end

end
{% endhighlight %}

This is no good because we keep repeating `if @verbose`.  We have
duplicated how to decide whether or not to log.

This class also has too many concerns.  It must do whatever it is that
a Foo does, _and_ it must be concerened with how and whether log.  We
can fix the duplication, and give this class less responsibility.

# Logging gets a class of its own (but still no time travel)

Let's move how and whether to log into its own class:

{% highlight ruby %}
class Log

  def initialize(verbose)
    @verbose = verbose
  end

  def puts(s)
    puts s if @verbose
  end

  def print(s)
    print s if @verbose
  end

end
{% endhighlight %}

Foo now takes a log:

{% highlight ruby %}
class Foo

  def initialize(log)
    @log = log
  end

  def bar
    @log.print "bar starting..."
    # ...
    @log.puts " done"
  end

end
{% endhighlight %}

And in use:

{% highlight ruby %}
def use_foo(verbose)
  log = Log.new(verbose)
  Foo.new(log).bar
end

use_foo(true)    # => "bar starting... done"
use_foo(false)   # =>
{% endhighlight %}

This is much better.  How and whether to log is now in its own class.

But look at these two lines:

{% highlight ruby %}
    puts s if @verbose
    ...
    print s if @verbose
{% endhighlight %}

A condition that is repeated may be a sign of code that can benefit
from polymorphism.  Let's see how.

# Applying the Null Object pattern

Let's apply the [null object
pattern](http://en.wikipedia.org/wiki/Null_Object_pattern) to the
logger and see what happens.  We'll remove all of the conditional code
from Log:

{% highlight ruby %}
class Log

  def puts(s)
    puts s
  end

  def print(s)
    print s
  end

end
{% endhighlight %}

and introduce a NullLog which has the same signature, but does nothing:

{% highlight ruby %}
class NullLog

  def puts(s)
  end

  def print(s)
  end

end
{% endhighlight %}

Then, in use:

{% highlight ruby %}
def use_foo(verbose)
  log = (verbose ? Log : NullLog).new
  Foo.new(log).bar
end

use_foo(true)    # => "bar starting... done"
use_foo(false)   # =>
{% endhighlight %}

The Log class has retained the knowledge of _how_ to log, but it no
longer is responsible for knowing _whether_ to log.  We've given that
responsibility to the class that is creating the log instance.

## There's the time travel

Through the use of polymorphism and dynamic dispatch, we have
"time-traveled" the decision of whether to log from when the logging
is done to earlier in the program's execution, when the log object was
made.

# A Factory

There's another pattern I would usually apply here.  The creation of
the Log or NullLog can be moved into a [factory
method](http://en.wikipedia.org/wiki/Factory_%28object-oriented_programming%29):

{% highlight ruby %}
class Log

  def self.make(verbose)
    (verbose ? self : NullLog).new
  end

  ...

end
{% endhighlight %}

and in use:

{% highlight ruby %}
def use_foo(verbose)
  log = Log.make(verbose)
  Foo.new(log).bar
end

use_foo(true)    # => "bar starting... done"
use_foo(false)   # =>
{% endhighlight %}
