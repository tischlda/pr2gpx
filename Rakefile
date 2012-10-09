require 'rubygems'
require 'rubygems/package_task'
require 'rake/testtask'

spec = Gem::Specification.new do |s|
  s.platform = Gem::Platform::RUBY
  s.name         = 'pr2gpx'
  s.summary      = 'pr2gpx'
  s.version      = '0.2.1'
  s.homepage     = 'http://github.com/tischlda/pr2gpx'
  s.requirements = 'none'
  s.require_path = 'lib'
  s.executables  = 'pr2gpx'
  s.files        = Dir["{lib}/**/*.rb", "bin/*", "MIT-LICENSE", "README.md"]
  s.authors      = ["David Tischler"]
  s.email        = 'david.tischler@gmx.at'
  s.description  = <<EOD
Converts Winlink position reports sent or received with Airmail into GPX tracks or waypoints.
EOD

  s.add_runtime_dependency 'nokogiri', '>= 1.5.5'
end

Gem::PackageTask.new(spec) do |pkg|
end

Rake::TestTask.new do |t|
  t.libs.push "lib"
  t.test_files = FileList['test/**/*_test.rb']
  t.verbose = true
end