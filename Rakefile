# encoding: UTF-8

require 'bundler'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'
require 'pry'

desc 'Default: run specs & rubocop'
task test: [:spec, :rubocop]

desc 'Run specs'
RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = '--require ./spec/spec_helper'
end

desc 'Lint code'
RuboCop::RakeTask.new

Bundler::GemHelper.install_tasks

