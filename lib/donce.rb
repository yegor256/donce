# frozen_string_literal: true

# SPDX-FileCopyrightText: Copyright (c) 2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

require 'logger'
require 'os'
require 'qbash'
require 'securerandom'
require 'shellwords'
require 'timeout'

# Execute Docker container and clean up afterwards.
#
# This function helps building temporary Docker
# images, run Docker containers, and clean up afterwards — may be
# convenient for automated tests (for example, with Minitest):
#
#  class MyTest < Minitest::Test
#    def test_prints_hello_world
#      stdout = donce(
#        dockerfile: '
#          FROM ubuntu
#          CMD echo "Hello, world!"
#        '
#      )
#      assert_equal("Hello, world!\n", stdout)
#    end
#  end
#
# It's possible to pass a block to it too, which will lead to
# background execution of the container (in daemon mode):
#
#  def test_runs_daemon
#    donce(dockerfile: "FROM ubuntu\nCMD sleep 9999") do |id|
#      refute_empty(id)  # the ID of the container
#    end
#  end
#
# If you need to run +docker+ via +sudo+, simply set +DONCE_SUDO+ environment
# variable to any value.
#
# Author:: Yegor Bugayenko (yegor256@gmail.com)
# Copyright:: Copyright (c) 2025 Yegor Bugayenko
# License:: MIT
module Kernel
  # The name of the localhost inside Docker container.
  # @return [String] The hostname
  def donce_host
    OS.linux? ? '172.17.0.1' : 'host.docker.internal'
  end

  # Build Docker image (or use existing one), run Docker container, and then clean up.
  #
  # @param [String] dockerfile The content of the +Dockerfile+ (if array is provided, it will be concatenated)
  # @param [String] home The directory with Dockerfile and all other necessary files
  # @param [String] image The name of Docker image, e.g. "ubuntu:24.04"
  # @param [Logger] log The logging destination, can be +$stdout+
  # @param [String|Array<String>] args List of extra arguments for the +docker+ command
  # @param [Hash<String,String>] env Environment variables going into the container
  # @param [Hash<String,String>] volumes Local to container volumes mapping
  # @param [Hash<String,String>] ports Local to container port mapping
  # @param [Hash<String,String>] build_args Arguments for +docker build+ as +--build-arg+ may need
  # @param [Boolean] root Let user inside the container be "root"?
  # @param [String|Array<String>] command The command for the script inside the container
  # @param [Integer] timeout Maximum seconds to spend on each +docker+ call
  # @return [String] The stdout of the container
  def donce(dockerfile: nil, image: nil, home: nil, log: $stdout, args: '', env: {}, root: false, command: '',
            timeout: 10, volumes: {}, ports: {}, build_args: {})
    raise 'Either use "dockerfile" or "home"' if dockerfile && home
    raise 'Either use "dockerfile" or "image"' if dockerfile && image
    raise 'Either use "image" or "home"' if home && image
    raise 'Either "dockerfile", or "home", or "image" must be provided' if !dockerfile && !home && !image
    docker = ENV['DONCE_SUDO'] ? 'sudo docker' : 'docker'
    img =
      if image
        image
      else
        i = "donce-#{SecureRandom.hex(6)}"
        a = [
          "--tag #{i}",
          build_args.map { |k, v| "--build-arg #{Shellwords.escape("#{k}=#{v}")}" }.join(' ')
        ].join(' ')
        if dockerfile
          Dir.mktmpdir do |tmp|
            dockerfile = dockerfile.join("\n") if dockerfile.is_a?(Array)
            File.write(File.join(tmp, 'Dockerfile'), dockerfile)
            qbash("#{docker} build #{a} #{Shellwords.escape(tmp)}", log:)
          end
        elsif home
          qbash("#{docker} build #{a} #{Shellwords.escape(home)}", log:)
        else
          raise 'Either "dockerfile" or "home" must be provided'
        end
        i
      end
    container = "donce-#{SecureRandom.hex(6)}"
    begin
      stdout = nil
      code = 0
      begin
        cmd = [
          docker, 'run',
          block_given? ? '--detach' : nil,
          '--name', Shellwords.escape(container),
          OS.linux? ? nil : "--add-host #{donce_host}:host-gateway",
          args,
          env.map { |k, v| "--env #{Shellwords.escape("#{k}=#{v}")}" }.join(' '),
          ports.map { |k, v| "--publish #{Shellwords.escape("#{k}:#{v}")}" }.join(' '),
          volumes.map { |k, v| "--volume #{Shellwords.escape("#{k}:#{v}")}" }.join(' '),
          root ? nil : "--user=#{Shellwords.escape("#{Process.uid}:#{Process.gid}")}",
          Shellwords.escape(img),
          command
        ].compact.join(' ')
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
        yield container if block_given?
      ensure
        logs = qbash(
          "#{docker} logs #{Shellwords.escape(container)}",
          level: code.zero? ? Logger::DEBUG : Logger::ERROR,
          log:
        )
        stdout = logs if block_given?
        qbash("#{docker} rm --force #{Shellwords.escape(container)}", log:)
      end
      stdout
    ensure
      Timeout.timeout(10) do
        qbash("#{docker} rmi #{img}", log:) unless image
      end
    end
  end
end
