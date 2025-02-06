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

require 'os'
require 'qbash'
require 'securerandom'

# Execute one bash command.
#
# Author:: Yegor Bugayenko (yegor256@gmail.com)
# Copyright:: Copyright (c) 2024-2025 Yegor Bugayenko
# License:: MIT
module Kernel
  # Build Docker image (or use existing one), run Docker container, and then clean up.
  #
  # @param [String] dockerfile The content of the +Dockerfile+
  # @param [String] home The directory with Dockerfile and all other necessary files
  # @param [String] image The name of Docker image, e.g. "ubuntu:24.04"
  # @param [Logger] log The logging destination, can be +$stdout+
  def donce(dockerfile: nil, image: nil, home: nil, log: $stdout, args: '', env: {}, root: false, command: '',
            timeout: 10)
    raise 'Either use "dockerfile" or "home"' if dockerfile && home
    raise 'Either use "dockerfile" or "image"' if dockerfile && image
    raise 'Either use "image" or "home"' if home && image
    raise 'Either "dockerfile", or "home", or "image" must be provided' if !dockerfile && !home && !image
    docker = ENV['DONCE_SUDO'] ? 'sudo docker' : 'docker'
    img =
      if image
        image
      else
        i = "donce-#{SecureRandom.hex(8)}"
        if dockerfile
          Dir.mktmpdir do |home|
            File.write(File.join(home, 'Dockerfile'), dockerfile)
            qbash("#{docker} build #{Shellwords.escape(home)} -t #{i}", log:)
          end
        end
        i
      end
    container = "donce-#{SecureRandom.hex(8)}"
    host = OS.linux? ? '172.17.0.1' : 'host.docker.internal'
    begin
      stdout = nil
      code = 0
      begin
        cmd = [
          docker, 'run',
          block_given? ? '-d' : '',
          '--name', Shellwords.escape(container),
          OS.linux? ? '' : "--add-host #{host}:host-gateway",
          args,
          env.map { |k, v| "-e #{Shellwords.escape("#{k}=#{v}")}" }.join(' '),
          root ? '' : "--user=#{Shellwords.escape("#{Process.uid}:#{Process.gid}")}",
          Shellwords.escape(img),
          command
        ].join(' ')
        stdout, code =
          Timeout.timeout(timeout) do
            qbash(
              cmd,
              log:,
              accept: nil,
              both: true,
              env:
            )
          end
        unless code.zero?
          log.error(stdout)
          raise \
            "Failed to run #{cmd} " \
            "(exit code is ##{code}, stdout has #{stdout.split("\n").count} lines)"
        end
        if block_given?
          r = yield container, host
          return r
        end
      ensure
        qbash(
          "#{docker} logs #{Shellwords.escape(container)}",
          level: code.zero? ? Logger::DEBUG : Logger::ERROR,
          log:
        )
        qbash("#{docker} rm -f #{Shellwords.escape(container)}", log:)
      end
      stdout
    ensure
      Timeout.timeout(10) do
        qbash("#{docker} rmi #{img}", log:) unless image
      end
    end
  end
end
