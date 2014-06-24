---
layout: post
title: "Little sibling classes"
date: 2014-06-17 20:00:00
categories: ruby oop duck-typing
redirect_from: /ruby/oop/duck-typing/2014/06/17/little-sibling-classes.html
---

# Three classes squished into one

I was working with a class that held two boolean flags, and a little
bit of conditional logic:

{% highlight ruby %}
class OutputFragment

  attr_reader :value

  def initialize(value, optional, overflow)
    @value = value
    @optional = optional
    @overflow = overflow
  end

  def optional?
    @optional
  end

  def overflow?
    @overflow
  end

  def peek
    if @overflow
      "(overflow)"
    elsif @optional
      "[#{value}]"
    else
      @value
    end
  end

end
{% endhighlight %}

OutputFragment wasn't bad, but the code that created instances of of
it was:

{% highlight ruby %}
def add_string(value, optional: false)
  @fragments << OutputFragment.new(value, optional, false)
end

def set_overflow
  @fragments << OutputFragment.new("", false, true)
end
{% endhighlight %}

Just... yuck.  I could have used named arguments to make it more
readable:

{% highlight ruby %}
def add_string(value, optional: false)
  @fragments <<
    OutputFragment.new(value:value, optional: optional, overflow: false)
end

def set_overflow
  @fragments << OutputFragment.new(value:"", optional: false, overflow: true)
end
{% endhighlight %}

But that's just lipstick on a pig.  The real problem here is that
there are three separate classes being squished into one.  Let's look
at the possible values of the _optional_ and _overflow_ attributes,
and what type of fragment they represent:

    overflow    optional   type of fragment
       F           F        required
       F           T        optional
       T           F        overflow

# Splitting the class

So what if we actually make three separate classes, one for each type
of fragment?  Let's see what that looks like:

{% highlight ruby %}
class RequiredOutputFragment

  attr_reader :value

  def initialize(value)
    @value = value
  end

  def optional?
    false
  end

  def overflow?
    false
  end

  def peek
    value
  end

end
{% endhighlight %}

{% highlight ruby %}
class OptionalOutputFragment

  attr_reader :value

  def initialize(value)
    @value = value
  end

  def optional?
    true
  end

  def overflow?
    false
  end

  def peek
    "[#{@value}]"
  end

end
{% endhighlight %}

{% highlight ruby %}
class OverflowOutputFragment

  def value
    ""
  end

  def optional?
    false
  end

  def overflow?
    true
  end

  def peek
    "(overflow)"
  end

end
{% endhighlight %}

In a language without duck typing, these would each derive from some
interface or base class.  With duck typing, and in cases like this
where there is no shared behavior, there's no need (and even in cases
of shared behavior, mixin modules may be better than inheritance).

You might be thinking that the one class kind of exploded into a lot
code, and you'd be right.  So what's good about this?  We did get rid
of the two boolean flags, and of the conditional in `#peek`.  But
the real payoff comes where the classes are made:

{% highlight ruby %}
def add_string(value, optional: false)
  @fragments << if optional
                  OptionalOutputFragment
                else
                  RequiredOutputFragment
                end.new(value)
end

def set_overflow
  @fragments << OverflowOutputFragment.new
end
{% endhighlight %}

The removal of those boolean flags (and, in the case of
`OverflowOutputFragment`, of the `value` argument as well), makes this
code clearer, at least to me.  What do you think?
