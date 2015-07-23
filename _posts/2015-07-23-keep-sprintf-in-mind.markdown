---
layout: post
title: "Keep String#% in mind"
date: 2015-07-23 00:00:00
categories: ruby
---

When a Ruby program needs to embed the value of an expression in a
string, [string interpolation][1] is the go-to tool:

{% highlight ruby %}
name = "Fred"
puts "Hello, #{name}"
#=> "Hello, Fred"
{% endhighlight %}

But sometimes the string can get a little long:

{% highlight ruby %}
puts "#{blamee(longest_line.location)}: #{longest_line.location} is #{longest_line.length} bytes long"
{% endhighlight %}

This can be fixed by continuing the string on another line:

{% highlight ruby %}
puts "#{blamee(longest_line.location)}: #{longest_line.location} "\
  "is #{longest_line.length} bytes long"
{% endhighlight %}

But that's ugly.  Much prettier is to use the [String#%][2] method:

{% highlight ruby %}
puts '%s: %s is %d bytes long' % [
  blamee(longest_line.location),
  longest_line.location,
  longest_line.length,
]
{% endhighlight %}

This takes care of the long line.  It also puts each expression on a
line by itself, making it easier to read and edit.

String#% is a wrapper for [Kernel#sprintf][3], which has many useful
ways to format things.  This print statement left-justifies the
version string with a width of 9, and right-justifies the use count
with a width of 7:

{% highlight ruby %}
puts "version %-9s used %7d times from %s through %s" % [
  api_version.version,
  api_version.use_count,
  format_time(api_version.min_time),
  format_time(api_version.max_time),
]
# => version v3.1.0    used    2453 times from 2015-07-20 through 2015-07-22
# => version v3.0.0    used  138893 times from 2015-07-19 through 2015-07-23
{% endhighlight %}

And it does so while looking pretty.

So the next time you're interpolating and the string gets too long or
hard to read, consider the virtues of String#%.

[1]: https://en.wikibooks.org/wiki/Ruby_Programming/Syntax/Literals#Interpolation
[2]: http://ruby-doc.org/core-2.2.2/String.html#method-i-25
[3]: http://ruby-doc.org/core-2.2.2/Kernel.html#method-i-sprintf
