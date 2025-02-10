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
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

require 'English'

Gem::Specification.new do |s|
  s.required_rubygems_version = Gem::Requirement.new('>= 0') if s.respond_to? :required_rubygems_version=
  s.required_ruby_version = '>=3.0'
  s.name = 'donce'
  s.version = '0.1.0'
  s.license = 'MIT'
  s.summary = 'Builds and starts temporary Docker containers'
  s.description =
    'A one-function library that helps you build a temporary Docker ' \
    'image, run a temporary Docker container from it, and then clean ' \
    'up, deleting them both. This may be helpful for automated testing, ' \
    'when you test how your code might behave in an isolated environment. ' \
    'This may also be helpful when you need a custom Docker image with a ' \
    'tool inside, but Testcontainers don\' have such an image.'
  s.authors = ['Yegor Bugayenko']
  s.email = 'yegor256@gmail.com'
  s.homepage = 'http://github.com/yegor256/donce.rb'
  s.files = `git ls-files`.split($RS)
  s.rdoc_options = ['--charset=UTF-8']
  s.extra_rdoc_files = ['README.md', 'LICENSE.txt']
  s.add_dependency 'backtrace', '>0'
  s.add_dependency 'os', '>0'
  s.add_dependency 'qbash', '>0'
  s.metadata['rubygems_mfa_required'] = 'true'
end
