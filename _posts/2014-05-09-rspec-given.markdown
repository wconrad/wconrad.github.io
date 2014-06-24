---
layout: post
title: "rspec-given: Specs that read like Cucumber"
date: 2014-05-09 06:00:00
categories: ruby rspec testing
redirect_from:
- /ruby/rspec/testing/2014/05/08/rspec-given.html
- /rspec-given.html
---

I followed a chain of blog entries and comments where people were
discussing the merits of [TDD][2]; those lead to the essay
[Test-induced design damage][1] by DHH of Rails fame.  It's a good
essay.  And just to be clear, by "good" I don't necessarily mean "I
agree with it."  What I mean is that it makes interesting points that
will cause your neurons to fire.  At least, it did mine.  DHH is a
smart guy, and for heaven's sake, he _invented Rails_, so when he has
something to say about how Rails is best tested, it's worth reading.

DHH argues that slavish application of TDD can cause twisted designs,
code that is less clear than it would be otherwise.  I know that's
true _for me_ -- I've created less readable code in the name of making
it testable.  What I don't know is how much that's TDD's fault, and
how much is just me not seeing a better way to to it.

As an example of code distorting the design, DHH links to [a video by
the late Jim Weirich][3] (you know, the Rake guy), in which Jim
demonstrates the application of [hexagonal architecture][4] to Rails.
It's a good video, especially in conjunction with DHH's criticism.
And yes, "good" here means the same thing as it did above.

In the course of the demonstration, Jim showed how he writes rspec
tests (sorry, "specifications").  I saw a wonderful style of rspec I
hadn't seen before.  It looks like this:

    {% highlight ruby %}
    describe Stack do
      Given(:stack) { Stack.new }
      Given(:initial_contents) { [] }
      Given { initial_contents.each do |item| stack.push(item) end }
    
      Invariant { stack.empty? == (stack.depth == 0) }
    
      context "with an empty stack" do
        Given(:initial_contents) { [] }
        Then { stack.depth == 0 }
    
        context "when pushing" do
          When { stack.push(:an_item) }
    
          Then { stack.depth == 1 }
          Then { stack.top == :an_item }
        end
    
        context "when popping" do
          When(:result) { stack.pop }
          Then { result == Failure(Stack::UnderflowError, /empty/) }
        end
      end

      ...

    end
    {% endhighlight %}

This is an excerpt from [stack_spec.rb][5], which is part of Jim's
[rspec-given][6] gem.  If you've ever worked with Cucumber, you'll
recognize this style.  Here's a piece of a cucumber test so you can
see how similar they are:

    Background:
      Given the test server is started
      And a successful connection
  
    Scenario: No argument
      When the client successfully asks for help
      Then the server should return a list of commands
  
    Scenario: Known command
      When the client successfully asks for help for "NOOP"
      Then the server should return help for "NOOP"
  
    Scenario: Unknown command
      When the client successfully asks for help for "FOO"
      Then the server should return no help for "FOO"

At first, Jim's "given" syntax looks like it's just renaming some
methods: `let` becomes `Given`, `before(:each)` becomes `When`, and
`specify` or `it` becomes `Then`, but there's more going on.  One
thing I like is the addition of `And`: This is like a `Then`, but it
does not redo the setup.  It inherits the state left by the previous
`Then` or `And`.  That lets you do this (stolen from the gem's
README):

    {% highlight ruby %}
    Then { pop_result == :top_item }
    And  { stack.top == :second_item }
    And  { stack.depth == original_depth - 1 }
    {% endhighlight %}

Without rspec-given, you would it like this:

    {% highlight ruby %}
    specify do
      expect(pop_result).to eq :top_item
      expect(stack.top).to eq :second_item
      expect(stack.depth).to eq original_depth - 1
    end
    {% endhighlight %}

Now, this kind of test, where you repeatedly poke at an object and
check the results of the accumulated state changes, isn't my favorite
way of writing tests.  I usually prefer that each test checks just one
thing.  But there are some tests that are easier to write and read in
this rolling style.  Jim's syntax is nice for those.

Jim's syntax pleases me very much.  Also, the [README][6] is very well
written, with just the right level of detail.  I'm going to give
rspec-given a try on my next project.

[1]: http://david.heinemeierhansson.com/2014/test-induced-design-damage.html
[2]: http://en.wikipedia.org/wiki/Test-driven_development
[3]: https://www.youtube.com/watch?v=tg5RFeSfBM4
[4]: http://alistair.cockburn.us/Hexagonal+architecture
[5]: https://github.com/jimweirich/rspec-given/blob/2fd1771f25deaaf9cb58e619ff80bfdb3ddaabe0/examples/stack/stack_spec.rb
[6]: https://github.com/jimweirich/rspec-given
