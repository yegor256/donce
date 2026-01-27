# frozen_string_literal: true

# SPDX-FileCopyrightText: Copyright (c) 2024-2026 Yegor Bugayenko
# SPDX-License-Identifier: MIT

require 'logger'
require 'loog'
require 'minitest/autorun'
require_relative '../lib/donce'

# Test for the Donce module functions.
# Author:: Yegor Bugayenko (yegor256@gmail.com)
# Copyright:: Copyright (c) 2024-2026 Yegor Bugayenko
# License:: MIT
class TestDonce < Minitest::Test
  def test_runs_simple_echo
    stdout = donce(dockerfile: "FROM ubuntu\nCMD echo hello", stdout: Loog::NULL, stderr: Loog::NULL)
    assert_equal("hello\n", stdout)
  end

  def test_prints_build_args
    stdout = donce(
      dockerfile: [
        'FROM ubuntu',
        'ARG FOO=what?',
        'RUN echo $FOO > /tmp/foo',
        'CMD cat /tmp/foo'
      ],
      build_args: { 'FOO' => 'hello' },
      stdout: Loog::NULL, stderr: Loog::NULL
    )
    assert_equal("hello\n", stdout)
  end

  def test_runs_existing_image
    stdout = donce(image: 'ubuntu:22.04', command: 'echo hello', stdout: Loog::NULL, stderr: Loog::NULL)
    assert_equal("hello\n", stdout)
  end

  def test_runs_from_home
    Dir.mktmpdir do |home|
      File.write(File.join(home, 'Dockerfile'), "FROM ubuntu\nCMD echo hello")
      stdout = donce(home:, stdout: Loog::NULL, stderr: Loog::NULL)
      assert_equal("hello\n", stdout)
    end
  end

  def test_copies_resources
    content = 'hello!'
    Dir.mktmpdir do |home|
      File.write(File.join(home, 'test.txt'), content)
      File.write(
        File.join(home, 'Dockerfile'),
        [
          'FROM ubuntu',
          'WORKDIR /foo',
          'COPY test.txt .',
          'CMD cat test.txt'
        ].join("\n")
      )
      stdout = donce(home:, stdout: Loog::NULL, stderr: Loog::NULL)
      assert_equal(content, stdout)
    end
  end

  def test_passes_gid_and_uid
    Dir.mktmpdir do |home|
      FileUtils.touch(File.join(home, 'bar.txt'))
      File.write(
        File.join(home, 'Dockerfile'),
        [
          'FROM ubuntu',
          'ARG UID',
          'ARG GID',
          'RUN groupadd -g ${GID} foo || true',
          'RUN useradd -m -u ${UID} -g ${GID} foo || true',
          'USER foo',
          'WORKDIR /foo',
          'COPY --chown=${UID}:${GID} bar.txt .',
          'CMD touch bar.txt'
        ].join("\n")
      )
      donce(home:, stdout: Loog::NULL, stderr: Loog::NULL)
    end
  end

  def test_runs_daemon
    seen = false
    donce(dockerfile: "FROM ubuntu\nCMD while true; do sleep 1; echo sleeping; done", stdout: Loog::NULL, stderr: Loog::NULL) do |id|
      seen = true
      refute_empty(id)
      sleep 1
    end
    assert(seen)
  end

  def test_returns_stdout_from_daemon
    stdout = donce(dockerfile: "FROM ubuntu\nCMD echo hello", stdout: Loog::NULL, stderr: Loog::NULL) { |_| sleep 0.1 }
    assert_equal("hello\n", stdout)
  end
end
