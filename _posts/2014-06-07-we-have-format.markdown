---
layout: post
title: "We have FORMAT"
date: 2014-06-07 06:00:00
categories: fortran
redirect_from: /fortran/2014/06/06/we-have-format.html
---

We have FORMAT statements.  This code:

{% highlight fortran %}
      PRINT 10, 1
      PRINT 10, 1, 2
      PRINT 10, 1, 2, 3
 10   FORMAT (I3, I3)
      END
{% endhighlight %}

writes this output:

      1
      1  2
      1  2
      3

It took a lot of thought to do this simple thing in a way that
promises spec compliance.

Now I've got to go back and fix all the TODOs, like these:

{% highlight ruby %}
    #TODO Use a hash to lookup labeled statements
    def labeled_statement(line_number)
      statement = @statements.find do |statement|
        #TODO why is the variable called line_number, but the method
        #     talks about a label?
        statement.label_matches?(line_number)
      end
      unless statement
        raise LabelNotFound, "Label not found: #{line_number}"
      end
      statement
    end
{% endhighlight %}

When doing a refactoring or adding a feature, I often see things that
need to be changed.  If they're trivial, I just do it.  But if they
require any thought at all (or especially if the tests aren't passing
at the moment), I defer them to later by adding a TODO comment.  After
I commit code, then I find and fix all the TODOs.

Especially early on, each TODO I fix can result in two more being
added.  That's because I'm still exploring the design, trying
different names, etc., and there are a lot of things that aren't quite
right.  But that's not what happened this time.  I was so interested
in getting FORMAT working that I implemented it _before_ doing all the
TODOs.  In the course of doing FORMAT, I added quite a few of them.
Now there are 18.  They're not broken windows, just dirty ones, but
they add up to code that isn't quite right.  It's time to roll up my
sleeves and fix them.
