# Builds Docker image, runs it, and kills

[![DevOps By Rultor.com](https://www.rultor.com/b/yegor256/donce)](https://www.rultor.com/p/yegor256/donce)
[![We recommend RubyMine](https://www.elegantobjects.org/rubymine.svg)](https://www.jetbrains.com/ruby/)

[![rake](https://github.com/yegor256/donce/actions/workflows/rake.yml/badge.svg)](https://github.com/yegor256/donce/actions/workflows/rake.yml)
[![PDD status](https://www.0pdd.com/svg?name=yegor256/donce)](https://www.0pdd.com/p?name=yegor256/donce)
[![Gem Version](https://badge.fury.io/rb/donce.svg)](https://badge.fury.io/rb/donce)
[![Test Coverage](https://img.shields.io/codecov/c/github/yegor256/donce.svg)](https://codecov.io/github/yegor256/donce?branch=master)
[![Yard Docs](https://img.shields.io/badge/yard-docs-blue.svg)](https://rubydoc.info/github/yegor256/donce/master/frames)
[![Hits-of-Code](https://hitsofcode.com/github/yegor256/donce)](https://hitsofcode.com/view/github/yegor256/donce)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](https://github.com/yegor256/donce/blob/master/LICENSE.txt)

This small Ruby library helps to build temporary [Docker]
images, run Docker containers, and clean up afterwards — it may be
convenient for automated tests (for example, with [Minitest]):

```ruby
class MyTest < Minitest::Test
  def test_prints_hello_world
    stdout = donce(
      dockerfile: '
        FROM ubuntu
        CMD echo "Hello, world!"
      '
    )
    assert_equal("Hello, world!\n", stdout)
  end
end
```

It's possible to run a Docker image in background mode too:

```ruby
stdout = donce(image: 'ubuntu', command: 'sleep 9999') do |id|
  # The "id" is the container id
  # The "donce_host()" is the hostname of it
end
```

If you set `DONCE_SUDO` environment variable to `true`,
  `docker` will be executed via `sudo`.

Host group/user IDs are passed to the build, as `GID` and `UID` args.
You can use them, when you copy resources into the image, for example:

```dockerfile
FROM ubuntu
ARG UID
ARG GID
RUN groupadd -g ${GID} foo || true
RUN useradd -m -u ${UID} -g ${GID} foo
USER foo',
WORKDIR /foo
COPY --chown=${UID}:${GID} bar.txt .
```

The `bar.txt` file is not ready to be modified inside the container.

## Parameters

Here's a list of the available parameters for `donce`:

* `dockerfile`: Content of the Dockerfile (string or array of strings)
* `home`: Directory with Dockerfile and all other necessary files
* `image`: Name of a Docker image to use (e.g. "ubuntu:22.04")
* `log`: Logging destination (defaults to $stdout)
* `args`: Extra arguments for the docker command
* `env`: Environment variables mapping for the container
* `volumes`: Local to container volumes mapping
* `ports`: Local to container port mapping
* `build_args`: Arguments for docker build (--build-arg)
* `root`: Let user inside the container be "root" (default: false)
* `command`: The command to execute in the container
* `timeout`: Maximum seconds to spend on each docker call (default: 10)

The function `donce_host()` returns the hostname of the host machine that
can be used from within the container.

## How to contribute

Read
[these guidelines](https://www.yegor256.com/2014/04/15/github-guidelines.html).
Make sure your build is green before you contribute
your pull request. You will need to have
[Ruby](https://www.ruby-lang.org/en/) 3.0+ and
[Bundler](https://bundler.io/) installed. Then:

```bash
bundle update
bundle exec rake
```

If it's clean and you don't see any error messages, submit your pull request.

[Docker]: https://www.docker.com/
[Minitest]: https://github.com/minitest/minitest
