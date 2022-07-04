# frozen_string_literal: true

desc "Load gem inside irb console"
task :console do
  require "irb"
  require "irb/completion"
  require File.join(__FILE__, "../../lib/slideck")
  ARGV.clear
  IRB.start
end

task c: :console
