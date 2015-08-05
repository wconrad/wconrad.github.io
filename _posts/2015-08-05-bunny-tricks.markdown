---
layout: post
title: "A few tips for using bunny library with RabbitMQ"
date: 2015-08-05 12:00:00
categories: ruby
---

Some things I want to remember about using the bunny library to
publish and read messages from a RabbitMQ server.

# No blocking read

The bunny library does not have a blocking read, so you'll have to
synthesize it yourself:

{% highlight ruby %}
# Returns delivery_info, properties, body
def synchronous_get
  loop do
    a = @channel.basic_get(...)
    return a unless a.first.nil?
    sleep(4)
  end
end
{% endhighlight %}


# Publishing messages reliably

If you need to be sure that a message was accepted, you'll have to
jump through some hoops:

Set the channel into "confirm select" mode:

{% highlight ruby %}
@channel.confirm_select
{% endhighlight %}

Register a callback that will be
called if the message is returned:

{% highlight ruby %}
@exchange.on_return do
  @returned = true
end
{% endhighlight %}

Now, to publish a message:

{% highlight ruby %}
@returned = false
@exchange.publish(..., persistent: true)
@channel.wait_for_confirms
if @returned
  raise RoutingError, "Message could not be routed"
end
{% endhighlight %}
