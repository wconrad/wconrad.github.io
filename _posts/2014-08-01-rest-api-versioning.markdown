---
layout: post
title: "REST API Versioning"
date: 2014-08-01 11:00:00
categories: rest
---

These are notes summarizing my research into how to version a RESTful
API.  These notes do not represent actual experience.  They're just me
remembering links I found useful.

# Restful API

Cribbed from [Your API versioning is wrong...][1] by Troy Hunt.

There are three ways to version a RESTful API:

* Something in the URI (".../api/v2/...")
* Something in the request header ("api-version: 2")
* Something in the Accept header ("Accept: application/apiname.v2+json")

Troy does them all at the same time.  His framework makes it easy.

# Semantic versioning

RESTful routes use [semantic versioning][2], but only the major
version number is used because only breaking API changes matter.
Adding a route never hurt anyone.  Deleting one, or changing one's
meaning, does.

[rocketpants][3]

[1]: http://www.troyhunt.com/2014/02/your-api-versioning-is-wrong-which-is.html
[2]: http://semver.org/
[3]: https://github.com/Sutto/rocket_pants
