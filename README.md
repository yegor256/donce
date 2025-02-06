# Builds Docker image, runs it, and kills

[![DevOps By Rultor.com](http://www.rultor.com/b/yegor256/donce)](http://www.rultor.com/p/yegor256/donce)
[![We recommend RubyMine](https://www.elegantobjects.org/rubymine.svg)](https://www.jetbrains.com/ruby/)

[![rake](https://github.com/yegor256/donce/actions/workflows/rake.yml/badge.svg)](https://github.com/yegor256/donce/actions/workflows/rake.yml)
[![PDD status](http://www.0pdd.com/svg?name=yegor256/donce)](http://www.0pdd.com/p?name=yegor256/donce)
[![Gem Version](https://badge.fury.io/rb/donce.svg)](http://badge.fury.io/rb/donce)
[![Test Coverage](https://img.shields.io/codecov/c/github/yegor256/donce.svg)](https://codecov.io/github/yegor256/donce?branch=master)
[![Yard Docs](http://img.shields.io/badge/yard-docs-blue.svg)](http://rubydoc.info/github/yegor256/donce/master/frames)
[![Hits-of-Code](https://hitsofcode.com/github/yegor256/donce)](https://hitsofcode.com/view/github/yegor256/donce)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](https://github.com/yegor256/donce/blob/master/LICENSE.txt)

This small Ruby library helps building temporary [Docker]
images, run Docker containers, and clean up afterwards --- may be
convenient for automated tests:

```ruby
donce(
  dockerfile: '
    FROM ubuntu
    ENTRYPOINT ["/bin/bash", "echo", "hello, world!"]
  '
)
```

That's it.

## How to contribute

Read
[these guidelines](https://www.yegor256.com/2014/04/15/github-guidelines.html).
Make sure you build is green before you contribute
your pull request. You will need to have
[Ruby](https://www.ruby-lang.org/en/) 3.2+ and
[Bundler](https://bundler.io/) installed. Then:

```bash
bundle update
bundle exec rake
```

If it's clean and you don't see any error messages, submit your pull request.

[Docker]: https://www.docker.com/
