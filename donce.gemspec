# frozen_string_literal: true

# SPDX-FileCopyrightText: Copyright (c) 2024-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

require 'English'

Gem::Specification.new do |s|
  s.required_rubygems_version = Gem::Requirement.new('>= 0') if s.respond_to? :required_rubygems_version=
  s.required_ruby_version = '>=3.0'
  s.name = 'donce'
  s.version = '0.0.0'
  s.license = 'MIT'
  s.summary = 'Builds and starts temporary Docker containers'
  s.description =
    'A one-function library that helps you build a temporary Docker ' \
    'image, run a temporary Docker container from it, and then clean ' \
    'up, deleting them both. This may be helpful for automated testing, ' \
    'when you test how your code might behave in an isolated environment. ' \
    'This may also be helpful when you need a custom Docker image with a ' \
    'tool inside, but Testcontainers don\'t have such an image.'
  s.authors = ['Yegor Bugayenko']
  s.email = 'yegor256@gmail.com'
  s.homepage = 'https://github.com/yegor256/donce'
  s.files = `git ls-files`.split($RS)
  s.rdoc_options = ['--charset=UTF-8']
  s.extra_rdoc_files = ['README.md', 'LICENSE.txt']
  s.add_dependency 'backtrace', '~> 0.3'
  s.add_dependency 'os', '~> 1.1'
  s.add_dependency 'qbash', '~> 0.3'
  s.metadata['rubygems_mfa_required'] = 'true'
end
