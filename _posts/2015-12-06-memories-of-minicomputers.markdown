---
layout: post
title: "Memories of minicomputers: The Modcomp II, and the Data General Nova"
date: 2015-12-06 12:00:00
categories: retrocomputing
---

Once upon a time, I worked in a small computer lab attached to an
Exxon Nuclear research facility.  There were two 16-bit minicomputers:
a [Modcomp][2] II that my boss and I programmed, and a [Data General
Nova][3] that another small team programmed.  The computers were
hooked up to a laser lab where humongous no-kidding
burn-holes-in-things lasers were being used to refine uranium.  I
can't tell you how powerful the lasers were, because that was
(probably still is) classified, but I've forgotten anyhow.  State
secrets are safe with someone whose memory is as bad as mine.

The Modcomp II minicomputer that I programmed was hooked up to sensors
that the computer used to collect data during the experiments, storing
the data to disk files.  My boss wrote the software that collected the
data, and I wrote the FORTRAN IV programs that charted the data.  We
had this fancy Techtronics graphing terminal that my code would draw
on, and then a thermal printer that could produce a monochome picture
of what was on the screen.  After an experiment, I ran my program,
took screen prints of the graphs, made copies, and carried the results
around to the scientists and engineers.  It was fun work, and it was
satisfying to have an important part to play.

The Modcomp II was just used for data acquisition--it had no way to
influence the world.  The Data General Nova was (I believe--this was a
while ago) used for real-time control of certain parts of the
experiment.  Like the Modcomp II, it was hooked up to various sensors,
but it also had outputs that it could use to drive things.  If I
remembered what it could control, I probably couldn't say, but again,
I've forgotten so those secrets are safe.

I enjoyed programming that Modcomp.  By today's standards, it was
minimal (64K x 16-bits of RAM), but the processor was pretty fast and
it had a lot of I/O bandwidth.  The instruction set was friendly to
write assembly language in, and the OS and compilers were capable.
But what it wasn't was sexy.  It came in two 19-inch rack-mount
cabinets, full of huge wire-wrapped planes covered with ICs on one
side and a dense mat of wires on the other.  The OS was reminiscent of
mainframes of old.  There's just nothing exciting about that.

The Data General Nova was, in my mind, sexier than the Modcomp II.
Its panel looked more modern to me.  It was soldered instead of
wire-wrapped, which seemed better (it was more reliable, anyhow).  Its
OS had a more modern feel to it, more like those of the microcomputers
that were bursting on the scene.  I remember looking over at the guys
programming it and feeling a little bit jealous.  Even though I
enjoyed the Modcomp, the Nova looked like more fun.  It might have
been a case of "the grass is greener" syndrome.

I never did get a chance to program that Nova, but it turns out that
the [simh][1] project can simulate it, _and_ they have a licensed copy
of the RDOS operating system.  Finally, I get a chance to play with
the Nova and learn what it's about.  In future blog entries, I will
write about my discoveries as I explore the simulated Data General
Nova.  In the next blog entry, I'll show how to get simh simulating
the Nova even if you know nothing about either.  It'll be a sort of
simh/nova "hello world."

[1]: https://github.com/simh/simh
[2]: https://en.wikipedia.org/wiki/MODCOMP
[3]: https://en.wikipedia.org/wiki/Data_General_Nova
