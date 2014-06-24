---
layout: post
title: "Bug Report == Cucumber Scenario?"
date: 2014-03-06 06:19:00
categories: cucumber
redirect_from: /cucumber/2014/03/05/bug-report-eq-cucumber-scenario.html
---

It wasn't until after I created [this bug
report](https://github.com/gollum/gollum/issues/811):

    When non-bare
    
    If I do this:
    
        $ git clone https://github.com/mojombo/gollum-demo gollum-demo-nonbare
        $ cd gollum-demo-nonbare
        $ gollum --show-all
    
    And then browse
    
        http://localhost:4567/Mordor/Eye-Of-Sauron
    
    I see the pictures of the eye of Sauron.

that I realized how similar it was to a [Cucumber
scenario](https://github.com/cucumber/cucumber/wiki/Feature-Introduction):

    Scenario: Buy last coffee
      Given there are 1 coffees left in the machine
      And I have deposited 1$
      When I press the coffee button
      Then I should be served a coffee

I like it.  I don't know if this is a good form for every bug report,
but it's nice to read, and clearly separates the setup from the action
from the result.
