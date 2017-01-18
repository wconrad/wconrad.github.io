---
layout: post
title: "Jörg W Mittag: How functional languages handle side-effects"
date: 2017-01-18 00:00:00 -07:00
categories: languages
---

On the [stackoverflow Ruby chat](https://chat.stackoverflow.com/),
conversation about the difference between statements and expressions
soon turned to a
[discourse](https://chat.stackoverflow.com/transcript/44914) about how
functional languages handle side-effects such as printing.  Parts of
that conversation are reproduced here with the permission of
participants [Jörg W
Mittag](https://stackoverflow.com/users/2988/j%C3%B6rg-w-mittag) and
[Marc-Andre](https://stackoverflow.com/users/2115680/marc-andre).

Jörg W Mittag:

> An expression evaluates to a value. A statement has no value, only a
side-effect.  Ruby has only expressions, there are no statements. Even
a method definition, a module/class definition, or a loop return
values. (Even if that value is just nil.)

> The thing is that this distinction is somewhat arbitrary. In fact,
languages which distinguish between both usually have an "expression
statement", which is a statement that consists only of a single
expression and throws away its value. They also sometimes have
"statement expressions" which are expressions that consist of a
statement and evaluate to some bogus value (e.g. NULL).

> Functional languages typically have no statements. After all, they
are all about values and something that has no value has no value in
FP ;-)

> What impure functional languages have instead is a "Unit Type". The
unit type is a type that is only inhabited by one value. Typically,
that value (and the type) is written as (), i.e. the empty
tuple. (There can only be one tuple that has no element.) "Statements"
are then expressions of type (), and "void procedures" are functions
that return (). E.g. in Scala, println returns Unit and assignment
evaluates to ().

Marc-Andre:

> I think I get it, but it still a bit blurry, but it's a bit better
now. Since some statement don't return value per se, they use a
generic value to return something?

Jörg W Mittag:

> In a pure functional language, the very idea of a statement doesn't
make sense: there are no side-effects, so something that doesn't
return a value just doesn't do anything.

Marc-Andre:

> In a pure functional language what would a println function return
or would it even be define like a "normal" println ?

Jörg W Mittag:

> However, in an impure language, there can be side-effects. One way
of handling this is to separate things that have values (expressions,
functions) from things that have side-effects (statements,
procedures). But that complicates the language and the syntax. So,
what we do instead is to define a value that carries zero information
(like the empty tuple) of a type that has this value as its only
instance, and define this "information-less" value as the return value
of something that has no meaningful value. Kind-of like puts in Ruby
returns nil, because, well, there is no meaningful thing it could
return.  @Marc-Andre In a pure functional language, println would take
two arguments: a string and the state of the world, and return a new
state of the world in which the string is printed to the screen. (At
least that's one way to interpret it.)

> However, we have a problem here: the caller could have held onto the
old world value! Now our caller has two worlds at its disposal: one in
which the string is printed and one in which it isn't. What do we do
if it calls println again with the old world value as input? We can't
"unprint" what we printed (especially if we printed to an actual
printer instead the screen.)  We need to make sure that "Worlds" don't
get re-used. There are some type system tricks we can use: there is a
concept called linear types, which are types that can only be used
once. Clean works this way, all IO functions take and return World
types that are based on linear types.

> Haskell goes a different route: it uses a concept called
monads. Monads allow you to "enrich" a computation with additional
structure but hide that structure away from the computation. So, the
"world values" never actually get exposed, they are always hidden (and
since they are never exposed, they don't even really exist in the
runtime at all).  In both cases, the result is the same: the pure
functional program returns a purely functional value that is basically
a description of the side-effects that the program would like to
perform. This description is then interpreted by the impure language
runtime. This allows the programming language semantics themselves to
remain pure.  Someone once said that Haskell has better support for
side-effects than C, since in Haskell, they are first-class, can be
passed around as arguments, can be returned as values, can be stored
in variables, can be composed. In C, they just happen.

Marc-Andre:

> Really interesting! It really amazing how "simple" things like
printing to a screen, can be such an important task and need a lot of
thought to it!

Jörg W Mittag:

> Purely functional programming would be pretty boring otherwise. You
need side-effects, otherwise all you do is make the CPU hot. Which,
some might argue, is also a side-effect.
