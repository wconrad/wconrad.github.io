---
layout: post
title: "More ConcatenatingEnumerator"
date: 2015-03-10 14:45:00 -07:00
categories: ruby
---

In a previous article I introduced a [Concatenating Enumerator][1].
Today I found a use for it in production code.  It could be that I
just [had a hammer and was looking for a nail][2], but I think the
code came out really clean.

# ConcatenatingEnumerator

Here's the concatenating  enumerator.  It lets you glue  any number of
enumerable things together and treat them as a single enumerator:

{% highlight ruby %}
class ConcatenatingEnumerator < Enumerator
  def initialize(enumerators = [])
    super() do |yielder|
      enumerators.each do |enumerator|
        enumerator.to_enum.each do |item|
          yielder.yield item
        end
      end
    end
  end
end
{% endhighlight %}

It can be used like this:

{% highlight ruby %}
enum1 = [1, 2, 3]
enum2 = [4, 5]
enum = ConcatenatingEnumerator.new([enum1, enum2])
p enum.to_a    #=> [1, 2, 3, 4, 5]
{% endhighlight %}

This example uses #to_a, but any of the usual enumeration methods will
work on a ConcatenatingEnumerator: #each, #first, #map, and so on.

Since ConcatenatingEnumerator calls `#to_enum` on its arguments, it
will take either enumerators, or anything that can be treated as an
enumerator (like Array).  (Calling #to_enum is a change from the
previous version of ConctatenatingEnumerator).

# Using ConcatenatingEnumerator to read log files

## The main method

The application parses one or more log files and prints some
statistics.  Here's the program's main method:

{% highlight ruby %}
logs = Logs.new(@args.paths)
stats = Stats.new
parser = Parser.new(stats)
logs.each do |line|
  parser.parse(line)
end
StatsPrinter.print(stats)
{% endhighlight %}

Even though this program reads multiple log files, the main method
isn't concerned with that.  The `Logs` class treats all the log files
as a single enumeration.  This makes the main method's life easy, and
its logic is easy to follow.  Only the highest level of abstraction is
visible here.

## Logs

`Logs` is perfectly simple:

{% highlight ruby %}
class Logs < ConcatenatingEnumerator

  def initialize(paths)
    logs = paths.map { |path| Log.new(path) }
    super(logs)
  end

end
{% endhighlight %}

We turn the log paths into instances of `Log`.  A `Log` is enumerable,
so ConcatenatingEnumerator can glue them together into a single
enumeration.

## Log

A `Log` is more interesting, because we want to open each file as
needed, and close it as soon as possible.  That way, the program only
needs to have one file open at a time.

{% highlight ruby %}
class Log

  def initialize(path)
    @path = path
  end

  def to_enum
    Enumerator.new do |yielder|
      File.open(@path, "r") do |file|
        file.each_line do |line|
          yielder.yield(line)
        end
      end
    end
  end

end
{% endhighlight %}

`#to_enum` is what lets the ConcatenatingEnumerator use this object.
The method returns an enumerator.  When that enumerator is used (and
not before), the file is opened, and each line is yielded in turn.
Once all of the lines are yielded, the file is closed.

# The real program does more

This code teeters on the edge of too much abstraction.  There's a lot
of mechanism being used to simply read some log files one after the
other.  The main method could be more like this, eliminating the
`Logs` class and the use of `ConcatenatingEnumerator`:

{% highlight ruby %}
stats = Stats.new
parser = Parser.new(stats)
@args.paths.each do |path|
  Log.open(path) do |log|
    log.each do |line|
      parser.parse(line)
    end
  end
end
StatsPrinter.print(stats)
{% endhighlight %}

But I prefer the more minimal main method that ConcatenatingEnumerator
makes possible.  You may reasonably disagree.

[1]: {% post_url 2014-06-03-concatenating-enumerator %}
[2]: http://en.wiktionary.org/wiki/if_all_you_have_is_a_hammer,_everything_looks_like_a_nail
