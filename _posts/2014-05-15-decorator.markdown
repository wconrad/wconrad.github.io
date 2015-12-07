---
layout: post
title: "Two ways to decorate a model in Ruby"
date: 2014-05-15 15:00:00 -07:00
categories: ruby design-patterns mvc
redirect_from:
- /ruby/design-patterns/mvc/2014/05/15/decorator.html
- /decorator.html
---

In applications using the MVC (Model View Controller) architecture, it
is good practice to:

* Keep the business logic in the model
* Keep the controller thin
* Keep logic out of the view

I've had few problems with keeping all of the business logic in the
model.  Keeping the controller thin can be more work, but it's not
usually too difficult.  Keeping logic out of the view, however, has
been more of a problem.  The two easiest ways to get the logic out of
the view are to move it into either a "helper function," or into the
model itself.  I'd like to explain the problems with these approaches,
and introduce the "decorator" pattern as an alternate solution.  I
will show how the decorate pattern is easily applied in Ruby through
the use of dynamically included modules.

# Let's Begin

Our example application will be a simple schedule with a list of
events.  It will make a schedule with some events, and then display
it.

We'll need some libraries:

{% highlight ruby %}
require 'date'
require 'delegate'
{% endhighlight %}

The models couldn't be simpler.

{% highlight ruby %}
Event = Struct.new(:name, :date)

class Schedule

  attr_reader :events

  def initialize
    @events = []
  end

end
{% endhighlight %}

The view is just a function that prints the schedule to the console:

{% highlight ruby %}
def show_schedule(schedule)
  case schedule.events.size
  when 0
    puts "Nothing to do.  Perfect!"
  when 1
    puts "Something to do.  Sigh."
  else
    puts "Much too much to do!"
  end
  schedule.events.each do |event|
    puts "#{event.date.strftime("%D")} - #{event.name}"
  end
end
{% endhighlight %}

This function is used by the controller to make a populated instance
of the Schedule model:

{% highlight ruby %}
def make_schedule
  schedule = Schedule.new
  schedule.events << Event.new('Mow the lawn', Date.new(2015, 1, 1))
  schedule.events << Event.new('Stop watering the lawn', Date.new(2015, 2, 1))
  schedule.events << Event.new('Rake up dead lawn', Date.new(2015, 6, 1))
  schedule
end
{% endhighlight %}

And this code, the controller proper, ties it all together.

{% highlight ruby %}
schedule = make_schedule
show_schedule schedule
{% endhighlight %}

And its outout:

    Much too much to do!
    01/01/15 - Mow the lawn
    02/01/15 - Stop watering the lawn
    06/01/15 - Rake up dead lawn

It works, but can it be better?  The logic in the view is distracting.
It would be better if the view did not have to concern itself with
details such as how to format the date, or how many tasks is "Much too
much to do!".  If we can move those logics out of the view, the view
becomes simpler.  Also, there may be other views of the same models
that wish to reuse those logics.  Let's explore some different ways to
achieve this.

# Helper methods

Let's try moving the view logics into helper functions.  This is an
approach commonly used in Ruby on Rails applications (although rails
calls them "helper methods," not "helper functions").

{% highlight ruby %}
class Bar
  def foo
    @foo
  end
end
{% endhighlight %}

Here are our helper functions:

{% highlight ruby %}
def format_event_date(event)
  event.date.strftime("%D %R")
end

def schedule_burden(schedule)
  case schedule.events.size
  when 0
    "Nothing to do.  Perfect!"
  when 1
    "Something to do.  Sigh."
  else
    "Much too much to do!"
  end
end
{% endhighlight %}

and here is the view that uses them:

{% highlight ruby %}
def show_schedule(schedule)
  puts schedule_burden(schedule)
  schedule.events.each do |event|
    puts "#{format_event_date(event)} - #{event.name}"
  end
end
{% endhighlight %}

This isn't bad.  The view is certainly cleaner now.  But helper
functions have a drawback: Being functions rathern than methods, the
helpers need to have all of the state they will act upon passed into
them.  That's the difference between a function and a method.  A
method acts upon an object's state; a function acts upon its
arguments.  Being functions, they are disconnected from the models
they act upon.  One of the principles of OOP is that data, and the
code that act upon that data, live together in an object.  Now we have
some code just "hanging out there."  An object's methods are
discoverable:

{% highlight ruby %}
p o.methods
{% endhighlight %}

But the functions are unattached to the object.  You just have to know
they are there.

# Adding view helpers to the models

One way to avoid the problem of disconnected helper functions is to
move the functions into the models they act upon.  Our models become:

{% highlight ruby %}
Event = Struct.new(:name, :date) do

  def format_date
    date.strftime("%D %R")
  end

end

class Schedule

  attr_reader :events

  def initialize
    @events = []
  end

  def burden
    case @events.size
    when 0
      "Nothing to do.  Perfect!"
    when 1
      "Something to do.  Sigh."
    else
      "Much too much to do!"
    end
  end

end
{% endhighlight %}

and the view:

{% highlight ruby %}
def show_schedule(schedule)
  puts schedule.burden
  schedule.events.each do |event|
    puts "#{event.format_date} - #{event.name}"
  end
end
{% endhighlight %}

This is just about ideal for the view.  It doesn't get any easier than
that.  Things aren't as good in the model.  The model's business
logical is now mixed in with the view's logic.  It's not so bad with
one view, but what if there were several views, each needing their own
special formatting and other logic?  The model ends up becoming a
Caddisfly larvae, covered with little pebbles and twigs that are
useful here and there, but a bit of a mess in the whole.  What we want
is the view we just made here, but without having to add those methods
to the model.  The decorator pattern can do that.

# Decorator using SimpleDelegator

What if we could decorate an instance of a model, adding to it the
methods that the view needs?  With Ruby's SimpleDelegator, we can do
it.

{% highlight ruby %}
class DecoratedSchedule < SimpleDelegator

  def burden
    case events.size
    when 0
      "Nothing to do.  Perfect!"
    when 1
      "Something to do.  Sigh."
    else
      "Much too much to do!"
    end
  end

end
{% endhighlight %}

A SimpleDelegator has an #initialize method that takes a single
argument, the delegatee, or class being delegated to.  In this case,
it will be an instance of Schedule.  The delegator forwards to the
delegatee any methods it doesn't know about.  It acts as though it is
the delegatee, but with some extra methods.  That's exactly what we
need!

A little change to the controller decorates the schedule before
showing it:

{% highlight ruby %}
schedule = make_schedule
schedule = DecoratedSchedule.new(schedule)
show_schedule schedule
{% endhighlight %}

We'll want to decorate the event, too.  Unfortunately, there's not an
easy way for us to do this outside the view.  We could do it where we
make the schedule:

{% highlight ruby %}
def make_schedule
  schedule = Schedule.new
  events = [
    Event.new('Mow the lawn', Date.new(2015, 1, 1)),
    Event.new('Stop watering the lawn', Date.new(2015, 2, 1)),
    Event.new('Rake up dead lawn', Date.new(2015, 6, 1))
  ]
  events.each do |event|
    event = DecoratedEvent.new(event)
    schedule.events << event
  end
end
{% endhighlight %}

But this is cumbersome.  And what if the code that makes the schedules
is used by other views?  We don't want to decorate _all_ events, we
just want to decorate the events used by this view.

We could also have the view do the decorating:

{% highlight ruby %}
def show_schedule(schedule)
  puts schedule.burden
  schedule.events.each do |event|
    event = DecoratedEvent.new(event)
    puts "#{event.format_date} - #{event.name}"
  end
end
{% endhighlight %}

but we're trying to make views _simpler_, not more complex.  If we
only needed to decorate a single, outer object, using delegators would
be alright.  But, in this case, our models are nested: A Schedule has
Tasks.  We want to decorate both the schedule and its tasks.  Which
leads us to:

# Mixin decorations

What if our helper methods were in modules?

{% highlight ruby %}
module ScheduleDecoration

  def burden
    case @events.size
    when 0
      "Nothing to do.  Perfect!"
    when 1
      "Something to do.  Sigh."
    else
      "Much too much to do!"
    end
  end

end

module EventDecoration

  def format_date
    date.strftime("%D %R")
  end

end
{% endhighlight %}

# Static mixins

The usual way people see modules used is at the class level, like this:

{% highlight ruby %}
class Schedule
  include ScheduleDecoration
  ...
end
{% endhighlight %}

This is a little better than just including the method directly into
the model: at least the module name serves to group methods according
to their purpose.  It's not ideal, though, since every instance of
that model has the decorations.  What happens when one view needs the
date formatted differently?  You end up having this:

{% highlight ruby %}
module EventDecoration
  def format_date_for_show
    ...
  end
end

module OtherEventDecoration
  def format_date_for_other_purpose
    ...
  end
end
{% endhighlight %}

This code is _not_ getting better.  But what if you could mix modules
into individual objects, so that the model gets decorated by the view
as needed?

# Dynamic mixins

Let's have the controller mix in the decorations at runtime, dynamically:

{% highlight ruby %}
def decorate_schedule(schedule)
  schedule.extend ScheduleDecoration
  schedule.events.each do |event|
    event.extend EventDecoration
  end
end

schedule = make_schedule
decorate_schedule schedule
show_schedule schedule
{% endhighlight %}

calling extend on an object and passing it a module, as here:

{% highlight ruby %}
  schedule.extend ScheduleDecoration
{% endhighlight %}

is almost the same as if the class included the module:

{% highlight ruby %}
class Schedule
  include ScheduleDecoration
  ...
end
{% endhighlight %}

_except_ that the module's methods are only included in that one
instance of Schedule rather than in every instance.  This is just what
we were looking for.  Now our controller can add the extra methods
that will make the view simple and clean, without polluting the model
class.

There's one more refinement we can make here.  The "decorate_schedule"
method is kind of annoying.  It's detail that our controller should
not have to worry about.  Also, if more than one controller needs the
same decoration, they would have to share the `decorate_schedule`
method.  That's not that bad, but let's see if we can tidy things up.

# Cleaning things up with Module.extended

You can make a module do things when it is extended.  Let's take the
loop out of `decorate_schedule` and move it into ScheduleDecoration:

{% highlight ruby %}
module ScheduleDecoration

  def self.extended(schedule)
    schedule.events.each do |event|
      event.extend EventDecoration
    end
  end

  def burden
    case @events.size
    when 0
      "Nothing to do.  Perfect!"
    when 1
      "Something to do.  Sigh."
    else
      "Much too much to do!"
    end
  end

end
{% endhighlight %}

Now the controller can simply decorate the schedule and the schedule's
tasks will also be decorated:

{% highlight ruby %}
schedule = make_schedule
schedule.extend ScheduleDecoration
show_schedule schedule
{% endhighlight %}

# The final result

We've made a lot of changes along the way.  Here's what the code looks
like now:

{% highlight ruby %}
require 'date'
require 'delegate'

Event = Struct.new(:name, :date);

class Schedule

  attr_reader :events

  def initialize
    @events = []
  end

end

module ScheduleDecoration

  def self.extended(schedule)
    schedule.events.each do |event|
      event.extend EventDecoration
    end
  end

  def burden
    case @events.size
    when 0
      "Nothing to do.  Perfect!"
    when 1
      "Something to do.  Sigh."
    else
      "Much too much to do!"
    end
  end

end

module EventDecoration

  def format_date
    date.strftime("%D %R")
  end

end

def make_schedule
  schedule = Schedule.new
  schedule.events << Event.new('Mow the lawn', Date.new(2015, 1, 1))
  schedule.events << Event.new('Stop watering the lawn', Date.new(2015, 2, 1))
  schedule.events << Event.new('Rake up dead lawn', Date.new(2015, 6, 1))
  schedule
end

def show_schedule(schedule)
  puts schedule.burden
  schedule.events.each do |event|
    puts "#{event.format_date} - #{event.name}"
  end
end

schedule = make_schedule
schedule.extend ScheduleDecoration
show_schedule schedule
{% endhighlight %}

and its output:

````
Much too much to do!
01/01/15 00:00 - Mow the lawn
02/01/15 00:00 - Stop watering the lawn
06/01/15 00:00 - Rake up dead lawn
````
