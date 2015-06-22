require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << 'test'
  t.test_files = ['test/handler.rb']
end

desc "Run tests"
task :default => :test

