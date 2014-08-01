---
layout: post
title: "Rails HATEOAS notes"
date: 2014-08-01 08:00:00
categories: rails rest hateoas
---

These are notes summarizing my research into how to fully implement
REST in Rails with JSON responses.  These notes do not represent
actual experience.  They're just me remembering links I found useful.

# Restful API

REST comes in levels, according to the Richardson Maturity Model as
[explained by Martin Fowler][1].

* Level 1 - Resources
* Level 2 - + verbs
* Level 3 - + hypermedia controls

Level 2 is what every Rails RESTful application does.

Level 3, Means that the response indicates what further routes the
client may wish to do.  If the client just created an object, the
response may include the routes to show or delete that object.

Level 3 is also called [HATEOAS<sup>1</sup>][4] (wikipedia), for
Hypermedia as the Engine of Application State.

Martin's article uses XML responses with <link> elements as defined by
the [ATOM publishing protocol][2] ([RFC 4287][3]), because "ATOM
... is generally seen as a leader in level 3 restfulness."

# How to get links into the JSON response in Rails

Most of this section is cribbed from [Rails Dilemma: HATEOAS in
XML/JSON Responses][5] by Andy Lindeman.

Here's an example of HATEOAS in a JSON response:

    {
      "book": {
        "id":1,
        "name":"Ender's Game",
        "isbn":"0812550706",
        "purchase_url":"http://www.example.com/books/1/purchase"
      }
    }

The `purchase_url` attribute is it.  Once you've got a book in your
hand, that's the URI to purchase it.

Andy's article is about how to properly architect your Rails
application to do this.  The issue is:

* The default rendering method is to call to_json on a model, but
* models don't have access to route helpers.

Andy describes several workarounds, but the winner looks like his
option 1: Render a view/partial that builds the JSON as needed.  Views
_do_ have access to route helpers.

Andy rejected option 1, but commenter Brandon Beacher explained why he
thinks it's best, and gave an [example][6] of how he's done it.  It
looks like an attractive approach to me.  The implementation looks
simple, it doesn't fight Rails, and his argument is compelling:

* "The json and xml representations of a model are just views, no?"

* "We'd never implement a to_html method on a model."

* "And we don't balk at creating html views because we'll have to
  maintain them as we add and remove attributes."

* "The json and xml views will be in the same folder alongside the
  html ones."

## Nick Sutterer's HAL proposal

Nick Sutterer [proposes the use of Mike Kelly's [HAL][8] protocol][7]
to encode links in the JSON response.  His starting example of a
RESTful JSON response differs from Andy Lindeman's example in that it
includes a _rel_ (relation) attribute.  This is the same information
included in the ATOM nodes in the XML responses that [Martin Fowler
shows][1].

    {"location":"desk",
     "fruits":[],
     "links":[
      {"rel":"self",  "href":"http://bowls/desk"},
      {"rel":"fruits","href":"http://bowls/desk/fruits"}
    ]}

After applying HAL, this becomes:

    {"location":"desk",
     "_embedded":{"fruits":[]},
     "_links":{
      "self":  {"href":"http://bowls/desk"},
      "fruits":{"href":"http://bowls/desk/fruits"}
    }}

* The _links section seems simple enough.
* _Leading _underscores _are _obnoxious.
* The _embedded section is for nested resources, I think..

I don't know if HAL is good or not.  It makes me uneasy--the responses
are starting to get complicated.  I don't know if it's as useful as it
is complex.

The money quote from Nick's article is this:

> "Roy Fielding, the inventor of REST, states that your API is RESTFUL
> if and only if it is hypermedia-driven! _In my words, that’ll mean
> no URL code should be hard-wired into your REST client – except for
> the single entry point URL._"  (italics mine)

-----

<sup>1</sup> _HATEOAS_?  Hate the Organization of American States?

[1]: http://martinfowler.com/articles/richardsonMaturityModel.html
[2]: http://atompub.org/rfc4287.html
[3]: http://tools.ietf.org/html/rfc4287
[4]: http://en.wikipedia.org/wiki/HATEOAS
[5]: http://www.andylindeman.com/2010/11/13/hateoas-in-rails.html
[6]: https://gist.github.com/brandon-beacher/766646
[7]: http://nicksda.apotomo.de/tag/hateoas/
[8]: http://stateless.co/hal_specification.html
