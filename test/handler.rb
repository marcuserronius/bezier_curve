require 'simplecov'
require 'test/unit'
$: << "lib"

# start simple coverage
SimpleCov.start

# find all test files in this dir, load them.
test_dir = File.expand_path("..",__FILE__)
Dir["#{test_dir}/test_*.rb"].each{|f|load f}
