# frozen_string_literal: true

# Copyright (c) 2025 Yegor Bugayenko
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the 'Software'), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

require 'minitest/autorun'
require 'loog'
require_relative '../lib/donce'

# Test.
# Author:: Yegor Bugayenko (yegor256@gmail.com)
# Copyright:: Copyright (c) 2025 Yegor Bugayenko
# License:: MIT
class TestDonce < Minitest::Test
  def test_runs_simple_echo
    stdout = donce(dockerfile: "FROM ubuntu\nCMD echo hello", log: Loog::NULL)
    assert_equal("hello\n", stdout)
  end

  def test_runs_existing_image
    stdout = donce(image: 'ubuntu:24.04', command: 'echo hello', log: Loog::NULL)
    assert_equal("hello\n", stdout)
  end

  def test_runs_from_home
    Dir.mktmpdir do |home|
      File.write(File.join(home, 'Dockerfile'), "FROM ubuntu\nCMD echo hello")
      stdout = donce(home:, log: Loog::NULL)
      assert_equal("hello\n", stdout)
    end
  end

  def test_runs_daemon
    seen = false
    donce(dockerfile: "FROM ubuntu\nCMD while true; do sleep 1; echo sleeping; done", log: Loog::NULL) do |id|
      seen = true
      refute_empty(id)
    end
    assert(seen)
  end
end
