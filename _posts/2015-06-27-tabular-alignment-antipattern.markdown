---
layout: post
title: "Avoid Tabular Alignment in Code"
date: 2015-06-27 16:00:00
categories: antipatterns ruby
---

Sometimes you'll see (or write) code like this:

{% highlight ruby %}
let(:resource) { FactoryGirl.create :device }
let(:type)     { Type.find resource.type_id }
{% endhighlight %}

or this:

{% highlight ruby %}
@cached_metadata = options[:metadata]
@logger          = options[:logger]
{% endhighlight %}

This show what I call "Tabular Alignment," the insertion of horizontal
white space to make certain elements of the code line up.  It makes
the code nicer to read, but it is costly to maintain.

# Makes Editing a Chore

Editing code that is tabular aligned can be a chore.  Suppose we are
starting with this:

{% highlight ruby %}
@cached_metadata = options[:metadata]
@logger          = options[:logger]
{% endhighlight %}

and need to add this:

{% highlight ruby %}
@cached_capabilities = options[:capabilities]
{% endhighlight %}

Since the width of the left column has changed, we need to edit every
line in the block in order to maintain the tabular alignment:

{% highlight ruby %}
@cached_metadata     = options[:metadata]        # edited
@logger              = options[:logger]          # edited
@cached_capabilities = options[:capabilities]    # added
{% endhighlight %}

Who wants to work that hard?

# Is Destroyed by Search/Replace

Search/Replace destroys tabular alignment.  Given this:

{% highlight ruby %}
@cached_metadata = options[:metadata]
@logger          = options[:logger]
{% endhighlight %}

Suppose we decide to rename `@cached_metadata` to `@metadata`, so we
use a search/replace operation to do it.  Now, we get this:

{% highlight ruby %}
@metadata = options[:metadata]
@logger          = options[:logger]
{% endhighlight %}

In order to preserve tabular alignment, we need to examine every line
of code where a replacement was done to ensure that tabular alignment
is maintained.

If the search/replace takes place in a mode that doesn't have you
review every replacement, you won't even know that you've messed up
some alignment.  The usual result is that misaligned code.

Now that's not pretty, is it?

# Makes a Mess of Version Control History

When a block of tabularly alined code needs to be realigned, the
version control system will treat each of those lines as having been
modified:

{% highlight diff %}
diff --git a/foo.rb b/foo.rb
index 40f7833..694d8fe 100644
--- a/foo.rb
+++ b/foo.rb
@@ -1,8 +1,8 @@
 class Foo
 
   def initialize(options)
-    @cached_metadata = options[:metadata]
-    @logger          = options[:logger]
+    @metadata = options[:metadata]
+    @logger   = options[:logger]
   end
 
 end
{% endhighlight %}

Now suppose that in the mean time, in another branch, a programmer has
added a new variable:

{% highlight diff %}
diff --git a/foo.rb b/foo.rb
index 40f7833..86648cb 100644
--- a/foo.rb
+++ b/foo.rb
@@ -3,6 +3,7 @@ class Foo
   def initialize(options)
     @cached_metadata = options[:metadata]
     @logger          = options[:logger]
+    @kittens         = options[:kittens]
   end
 
 end
{% endhighlight %}

Merging that branch will fail:

    wayne@mercury:/tmp/foo$ git merge add_kittens
    Auto-merging foo.rb
    CONFLICT (content): Merge conflict in foo.rb
    Automatic merge failed; fix conflicts and then commit the result.

Without tabular alignment, this merge would have succeeded
automatically.

Why make more work for ourselves?
