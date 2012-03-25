require 'changes_only_compiler'

abort "Usage: compile_changed.rb [rooms folder]" unless ARGV.size == 1

always_compile = [4165]
ChangesOnlyCompiler.new(ARGV.shift, always_compile).compile!