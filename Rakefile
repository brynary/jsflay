# require 'rubygems'
require "rake/gempackagetask"
require 'rake/rdoctask'
require "rake/clean"
require 'spec'
require 'spec/rake/spectask'
require File.expand_path('./lib/jsflay.rb')

spec = Gem::Specification.new do |s|
  s.name         = "jsflay"
  s.version      = JSFlay::VERSION
  s.platform     = Gem::Platform::RUBY
  s.author       = "Bryan Helmkamp"
  s.email        = "bryan" + "@" + "brynary.com"
  s.homepage     = "http://github.com/brynary/jsflay"
  s.summary      = "jsflay: Analyze JavaScript to eradicate duplication"
  s.bindir       = "bin"
  s.description  = s.summary
  s.require_path = "lib"
  s.files        = %w(History.txt MIT-LICENSE.txt README.rdoc Rakefile) + Dir["lib/**/*"]

  # Dependencies
  s.add_dependency "johnson", ">= 1.0.0"
end

Rake::GemPackageTask.new(spec) do |package|
  package.gem_spec = spec
end

desc 'Show information about the gem.'
task :debug_gem do
  puts spec.to_ruby
end

CLEAN.include ["pkg", "*.gem", "doc", "ri", "coverage"]

desc "Run API and Core specs"
Spec::Rake::SpecTask.new do |t|
  t.spec_opts = ["--color"]
end

desc 'Install the package as a gem.'
task :install_gem => [:clean, :package] do
  gem_filename = Dir['pkg/*.gem'].first
  sh "sudo gem install --no-rdoc --no-ri --local #{gem_filename}"
end

task :default => :spec