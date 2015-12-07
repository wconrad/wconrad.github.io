---
layout: post
title: "Tiny DSL using throw/catch"
date: 2015-07-14 12:00:00 -07:00
categories: ruby
---

Someone asked me whether I had used Ruby's [throw/catch][1] mechanism
in production.  I thought I had, but couldn't remember a specific
instance.  Today, I ran across some of my production code that uses
throw/catch.

The product has a form that the end user fills out in order to pay a
bill.  For the user's convenience, the form is prefilled from any of
several sources.  For example, if the user has made a payment before,
we'll use the address they filled in last time.  If they have not made
a payment but the system knows the address that their statement was
mailed to, it will use that.  There is also a test mode that can
provide prefills, and defaults to use when no prefill value is found.

The class that knows the prefill rules has a constructor that takes
the different objects that prefill information can come from:

{% highlight ruby %}
class BillPayPrefill

  def initialize(document, demo, merchant, bill_pay_request)
    @document = document
    @demo = demo
    @merchant = merchant
    @bill_pay_request = bill_pay_request
  end

  ...

end
{% endhighlight %}

There are about 20 fields, and so 20 methods to encapsulate the
business rules for how prefill works with each field.  At first, these
methods looked like this:

{% highlight ruby %}
def first_name
  if @bill_pay_request
    @bill_pay_request.billing_first_name
  elsif @document
    @document.first_name
  elsif test_mode?
    'BARNEY'
  else
    nil
  end
end
{% endhighlight %}

Just one or two methods like that is no big deal.  But with 20 of
them, we wanted a way to make the business rules stand out better.  We
ended up with this instead:

{% highlight ruby %}
def first_name
  get_value do
    from_request :billing_first_name
    from_document :first_name
    when_test_mode 'BARNEY'
    default nil
  end
end
{% endhighlight %}

The DSL that makes this work is implemented in just a few private
methods.  This is the first of them.  All it does is to catch a symbol
and then yield to the passed block:

{% highlight ruby %}
def get_value
  catch(:value) do
    yield
  end
end
{% endhighlight %}

The other methods throw a value, if it exists.  If the value does not
exist, they just return so that the next method can be tried:

{% highlight ruby %}
def from_request(request_attribute)
  if @bill_pay_request
    throw :value, @bill_pay_request.send(request_attribute)
  end
end

def from_document(document_attribute)
  if @document
    throw :value, @document.send(document_attribute)
  end
end

def when_test_mode(test_value)
  if test_mode?
    throw :value, test_value
  end
end

def default(default_value)
  throw :value, default_value
end
{% endhighlight %}

The result of the top-level `catch` is the result of the first `throw`
that gets executed.  Using throw/catch gives the DSL a nice way to
stop looking when the prefill value is found.

[1]: http://rubylearning.com/blog/2011/07/12/throw-catch-raise-rescue--im-so-confused/
