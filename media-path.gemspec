#!/usr/bin/env gem build
# encoding: utf-8

# NOTE: we can't use require_relative because when we run gem build, it use eval for executing this file
require "base64"

Gem::Specification.new do |s|
  s.name = "media-path"
  s.version = "0.1.4"
  s.authors = ["Jakub Šťastný aka Botanicus"]
  s.homepage = "http://github.com/botanicus/media-path"
  s.summary = "MediaPath abstraction that provides easier interaction with paths and corresponding URLs." # TODO
  s.description = "" # TODO
  s.email = Base64.decode64("c3Rhc3RueUAxMDFpZGVhcy5jeg==\n")
  s.has_rdoc = true

  # files
  s.files = `git ls-files`.split("\n")

  s.require_paths = ["lib"]

  # RubyForge
  s.rubyforge_project = "media-path"
end
