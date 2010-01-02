#!./script/nake
# encoding: utf-8

begin
  require_relative "gems/environment.rb"
rescue LoadError
  abort "You have to install bundler and run gem bundle first!"
end

ENV["PATH"] = "script:#{ENV["PATH"]}"

require "nake/tasks/gem"
require "nake/tasks/spec"
require "nake/tasks/release"

load "code-cleaner.nake"

unless File.exist?(".git/hooks/pre-commit")
  warn "If you want to contribute to MediaPath, please run ./tasks.rb hooks:whitespace:install to get Git pre-commit hook for removing trailing whitespace"
end

require_relative "lib/media-path"

# Setup encoding, so all the operations
# with strings from another files will work
Encoding.default_internal = "utf-8"
Encoding.default_external = "utf-8"

Task[:build].config[:gemspec] = "media-path.gemspec"
Task[:prerelease].config[:gemspec] = "media-path.pre.gemspec"
Task[:release].config[:name] = "media-path"
Task[:release].config[:version] = MediaPath::VERSION

Nake::Task["hooks:whitespace:install"].tap do |task|
  task.config[:path] = "script"
  task.config[:encoding] = "utf-8"
  task.config[:whitelist] = '(bin/[^/]+|.+\.(rb|rake|nake|thor|task))$'
end
