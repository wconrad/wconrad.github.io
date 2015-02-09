---
layout: post
title: "Debugging ActiveRecord Issues"
date: 2015-02-08 21:16:00
categories: ruby
---

Things I learned when exploring [an apparent issue with the
composite_primary_keys gem][1]:

* The [seed_dump][2] gem is a great way to capture the contents of a
  production database so that you can debug locally.

* Similarly, `rake db:dump` is good for capturing the schema of a
  production database.

* `rails g task` generates a skeleton rake task which has a database
  connection and access to the project's models.

* The [rails][3] project has great [bug report templates][4] for
creating stand-alone programs that reproduce an active-record issue.

[1]: https://github.com/composite-primary-keys/composite_primary_keys/issues/287
[2]: https://github.com/rroblak/seed_dump
[3]: https://github.com/rails/rails
[4]: https://github.com/rails/rails/tree/master/guides/bug_report_templates
