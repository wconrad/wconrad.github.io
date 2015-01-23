---
layout: post
title: "Why to check in a library's Gemfile.lock"
date: 2015-01-23 10:30:00
categories: ruby
---

It is common advice to not check your Gemfile.lock into version
control for a Ruby gem that is a library.  I think that advice is
wrong, at least for the way I work with gem libraries.

# The advice, and why I disagree with it

Here's the reason as [stated by Yehuda Katz][1] (_emphasis mine_):

> "This is also why we recommend that people do not check in their
> Gemfile.lock files in gem development. That file is emitted by
> bundler, and guarantees that all gems, including dependencies of
> dependencies, remain the same. However, when doing gem development,
> _you want to know immediately when some change in the overall
> ecosystem breaks your setup_. While you may want to insist on using
> a particular gem from its git location, you do not want to hardcode
> your development to a very specific set of gems, only to find out
> later that a gem released after you ran bundle install, but
> compatible with your version range, doesn’t work with your code."

Whether or not I check in the Gemfile.lock, _it exists on my drive_,
left over from the last time I did a "bundle install" in that project.
Because of that, I will _never_ know immediately that some later
version of a dependency has broken my gem.  I only get to find out
after I do a `bundle update`.

Not checking in the Gemfile.lock doesn't change that.

# Why "using a particular gem from its git location" does not matter.

One of the arguments against checking in Gemfile.lock is that it will
capture "diversions" made in the Gemfile to temporarily use a gem from
some path on your hard drive or from a particular git location.  I
don't understand this objection: When I add something like this to a
Gemfile:

    gem "foo", path: "/path/to/my/local/foo"

It's a temporary change that never gets checked into version control.
When I'm done making whatever changes that "foo" needs in order to
work with the new version of _this_ gem, and tests for both "foo" and
this gem are passing, I:

* publish foo
* Update this gem's gemspec to require the new version of foo
* Remove the diversion from this project's Gemfile
* run "bundle install" to remove the record of that diversion from the
  Gemfile.lock
* run tests

Only then do I check in my changes.  The diversion never gets
published, either to version control or to rubygems.org.  Since this
workflow never checks in "use this gem over there instead" diversions
made to Gemfile/Gemfile.lock, this reason is not a compelling reason
to keep Gemfile.lock out of version control.

# The harm of not checking in gemfile.lock

Here's the problem with not checking in Gemfile.lock.  Let's say I
decide to find out if any changes to the ecosystem _have_ broken my
gem, so I do a `bundle update`.  Since my Gemfile properly contains
the line "gemspec", the `bundle update` will get the latest versions
of the dependencies that are consistent with the version constraints
in the gemspec.  All is fine, until I run tests and find that some of
them are now broken.  Now, what information I have about what versions
changed?

Absolutely nothing.  Well, `bundler update` did tell me what version
of each gem it is using _now_, so I can scroll back and see, but I
have no information about what version was being used the last time I
ran the tests and had them pass.  That information is in the version
of the Gemfile.lock that just got clobbered.  However, if Gemfile.lock
were checked in, the version control system could tell I what version
I was running before.  I could even revert to the previous
Gemfile.lock and start over.  But if Gemfile.lock is not checked in,
the best I can do is to get the prior version of the Gemfile.lock from
my backups, if I have them.

# A reason that checking in Gemfile.lock might actually be bad.

There may be a good reason, not mentioned by Mrk. Katz, to keep
Gemfile.lock out of version control: So that continuous integration
tests can find out when changes in the ecosystem have broken your gem.
If you check in a Gemfile.lock, then when the CI system does a `bundle
install` and then `bundle exec rake test` (or whatever), it will run
with exactly the same gem versions you developed with.  That's fine
for showing that you didn't check in any test failures, but it won't
show you if the ecosystem has changed in a way that breaks your gem.
If you don't check in Gemfile.lock, then the "bundle install" done by
CI will get the latest version of every gem that is consistent with
the versions constraints in the gemspec.  In that case, the CI system
will be able to warn you that the ecosystem has broken your gem.

That's a plus, but not an overwhelming plus for me.  In any case, the
CI system could be made to do a "bundle update" before running tests;
that way the Gemfile.lock could be checked in and CI could still let
you know when the ecosystem has broken your gem.

[1]: http://yehudakatz.com/2010/12/16/clarifying-the-roles-of-the-gemspec-and-gemfile/
