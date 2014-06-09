---
layout: post
title: "Handling parse errors (cont'd)"
date: 2014-06-09 05:00:00
categories: fortran
---

In my investigation (that is, googling) of handling parse errors in a
recursive descent compiler with backtracking, I learned that a
recursive descent compiler with backtracking and ordered choice (which
is my parser) is, in fact a PEG (Parsing Expression Grammar).  I was
confused because most PEGs are so-called "packrat" parsers, which do
memoization in order to speed things up.  My parser does no
memoization, so I thought it wasn't a PEG.  Wrong.  It is.  It's just
not a particularly efficient one.

Anyhow.  My problem is that errors like the extra comma at the end of
the third PRINT statement:

{% highlight fortran %}
      PRINT *, 'a', 'bc'
      PRINT *
      PRINT *, 'def',
      END
{% endhighlight %}

Were causing useless error messages like this:

    Expected /\Z/ at "      PRINT *, 'a', 'bc'\n      PRINT *\n      PRINT *, 'def',\n      END\n"

Yuck.

# Turning a character offset into line and column number

Fixing this came in two parts.  The first part was being able to
report the line, line number, and column that the error occured at.
This was a problem because none of that information is directly
available at the point the error is recognized.  The parser uses
Ruby's
[StringScanner](http://www.ruby-doc.org/stdlib-2.1.1/libdoc/strscan/rdoc/StringScanner.html)
class, which treats the source as one big string.  The only position
information the parser has is the byte offset from the beginning of
the file.

I solved that by wrapping the source code in a class named (drumroll,
please)... Source.  Source responds to `#to_str`, so Ruby's
StringScanner works fine with it.  Yay for Ruby's type conversion
convensions.  Source has these methods:

{% highlight ruby %}
def line_position(source_position)
  i = 0
  @contents.each_line.with_index do |line, line_index|
    j = i + line.size
    if (i...j).include?(source_position)
      line_number = line_index + 1
      column_number = source_position - i
      return LinePosition.new(line_number, column_number)
    end
    i = j
  end
  raise ArgumentError, "Invalid source offset"
end

def line_at(line_number)
  @contents.lines[line_number - 1]
end
{% endhighlight %}

`Source#line_position` takes a character offset from the beginning of
the file and returns the corresponding line number and column number.
Line numbers start from 1 and column numbers from 0 because that's
what Emacs likes (when I put the cursor on the error message and hit
ENTER, Emacs will take me to that exact position in the source).

I'm not really proud of `Source#line_position`.  It just seems a lot
like what you'd write in C.  A lot of the time, if your algorithm
expressed in Ruby would be expressed similarly in C, there is a better
way to do it.  I'd like a more declarative, functional approach, but I
don't know it.

You'll notice that `#line_position` and `#line`_at both convert the
source to lines and then throw the lines away.  It doesn't make sense
here to cache the lines, because these two methods are each called
exactly once, when printing the error message before aborting.  Even
if the source is really big, they'll be fast enough.

# Which error to report?

The second part of the problem is having an error at the end of the
file produce an error message that points to the beginning.  That's
because of how I implemented backtracking in the parser.  Here's the
code to parse an arithmetic expression such as "1 + 2 + 3":

{% highlight ruby %}
def parse_arithmetic_expression
  left = parse_unary_expression
  while (operator = maybe { parse_additive_operator })
    right = parse_term
    left = BinaryOperation.new(left, operator, right)
  end
  left
end
{% endhighlight %}

It's interesting how easily this code handles left-associative
operators, something that was harder with the more formal parsers such
as Parslet.  But that's not why I'm showing this piece of code.  I
just had to mention it because, well, it is kinda pretty.

The call to `#maybe` is speculatively calling the method
`#parse_additive_operator`.  If that method succeeds, and parses an
additive operator, `#maybe` will return that.  However, if that method
raises a FortranSyntaxError exception, then maybe will backtrack to
where the parser was when `#maybe` was called, and then return nil.
`#maybe` is dirt simple:

{% highlight ruby %}
def zero_or_one
  bookmark = @scanner.bookmark
  begin
    yield
  rescue FortranSyntaxError
    @scanner.goto_bookmark bookmark
    nil
  end
end
alias :maybe :zero_or_one
{% endhighlight %}

`#maybe`, and methods like it, are the source of our problem, because
they consume Syntax errors.  The syntax error that was the root of the
problem disappears, and the method to parse the print statement ends
up raising its own Syntax error.  Each method to parse something was
called by another method to parse something; each of them ends up
eating one Syntax error and emitting another.  This continues to the
top:

{% highlight ruby %}
def parse_program_units
  program_units = zero_or_more { parse_program_unit }
  parse_end_of_source
  program_units
end
{% endhighlight %}

ultimately, `#parse_program_unit` fails, causing zero_or_more to
return an empty array and backtrack to the beginning of the program.
`parse_end_of_source` then finds we aren't at the end of the source
after all.  That raises the last, final syntax error, and the program
ends with an error messages no more helpful than the "Check Engine"
light on your car.

It might be more helpful to report on that first error.  But how do we
know which error is "first?"  This compiler raises syntax error
exceptions as part of how it works normally, so many syntax errors
have already occured on the way to the error that actually revealed
the problem.  The answer is to report the "deepest" error, the one
that occured the farthest into the file.  That will either be the
location of the actual error, or at least somewhat close to it.

So way, way down, at the point these errors are raised, we'll keep
track of which one occured the farthest into the file:

{% highlight ruby %}
def error(message = "Syntax error")
  error = FortranSyntaxError.new(message, @source, @scanner.pos)
  @deepest_error = error.deepest(@deepest_error)
  raise error
end
{% endhighlight %}

When creating the exception, we give it the source and the character
offset, which it can use later to give a useful error message.  Then,
we update @deepest_error, using `FortranSyntaxError#deepest`:

{% highlight ruby %}
def deepest(error)
  if error && error.source_position > @source_position
    error
  else
    self
  end
end
{% endhighlight %}

Finally, when the compiler gets a syntax error, it replaces it with
the deepest syntax error:

{% highlight ruby %}
def compile
  source = Source.from_file(@source_path)
  scanner = Scanner.new(source)
  parser = Parser.new(scanner)
  @program_units = parser.parse_program_units
rescue ParseError => e
  raise parser.deepest_error
end
{% endhighlight %}

That's pretty much it.

# The result

Here's the error message now:

    /home/wayne/lab/fortran77/gem/examples/print_character.f:3.21:
          PRINT *, 'def',
                        ^
    Error: Expected "'"

The actual text of the error message is as useless as ever, but now we
get an error position that's either at or close to the actual point of
error.  I think that'll be good enough to let me continue to implement
more of the language.  So, after I clean up a few TODO items that I
introduced (some code that could stand to have unit tests, etc.), then
it's back to the FORMAT statement.
