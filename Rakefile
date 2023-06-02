require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['Test/test*.rb']
  t.verbose = true
end

task default: [:test]