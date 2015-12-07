---
layout: post
title: "Handling parse errors"
date: 2014-06-08 05:00:00 -07:00
categories: fortran
redirect_from:
- /fortran/2014/06/07/handling-parse-errors.html
- /handling-parse-errors.html
---

I've plowed through the TODO list.  It feels good to have all those
little issues cleaned up.  I've also got the E, D, F, and G format
specifiers working, and mostly (I think) compliant with the spec.
Eventually I'll get this thing to the point where I can run the [NIST
Fortran 77 test
suite](http://www.fortran-2000.com/ArnaudRecipes/fcvs21_f95.html), and
then I'll find out for sure.  I expect that I'll be non-compliant in
enough areas that just getting the tests to run at all will be
difficult, but we'll see.

I also got a little bit more done on the FORMAT statement, which now
accepts the F (fixed), E (exponential), D (alias for E), G
(fixed/exponential, depending), a L (logical) edit descriptors:

{% highlight fortran %}
      PRINT 30, 123.456, 123.456, -123.456
 30   FORMAT (F8.3, E12.3, D12.3)
      PRINT 40, 0.1234, 0.1234E10
 40   FORMAT (G14.4)
      PRINT 50, .TRUE., .FALSE.
 50   FORMAT (L2)
      END
{% endhighlight %}

     123.456   0.123E+03  -0.123E+03
        0.1234    
        0.1234E+10
     T
     F

I want to go finish all of the other edit descriptors, but there's a
problem I can't ignore anymore: the parser's error reporting stinks.
I could explain it in all it's gory details, but I'll just show you
the horror of it.  Here's a short program with an erroneous trailing
comma in the last PRINT statement:

{% highlight fortran %}
      PRINT *, 'a', 'bc'
      PRINT *
      PRINT *, 'def',
      END
{% endhighlight %}

And the actual error message this generates:

    Expected /\Z/ at "      PRINT *, 'a', 'bc'\n      PRINT *\n      PRINT *, 'def',\n      END\n"

Basically, all you get is what string or regex was expected, and what
is left of the program, as one big string.  Because of backtracking,
the parser basically ends up telling you, "This doesn't match a
program.  Since it doesn't match a program, I expected the end of the
file, but instead found this program.  I tried a whole bunch of stuff,
which I've forgotten about so I can't tell you.  You'll have to figure
it out."

Nice, huh?

So now I've got to figure out how to get decent error reporting cooked
into this parser.  I've been putting it off because I have only a
vague idea how to go about it.  I can't put it off any longer.
