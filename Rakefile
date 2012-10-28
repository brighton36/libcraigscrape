require 'rake'
require 'rake/clean'
require 'rdoc/task'
require 'rake/testtask'
require 'fileutils'
require 'tempfile'

include FileUtils

RbConfig = Config unless defined? RbConfig

NAME = "libcraigscrape"
VERS = ENV['VERSION'] || "1.0"
PKG = "#{NAME}-#{VERS}"

RDOC_OPTS = ['--quiet', '--title', 'The libcraigscrape Reference', '--main', 'README', '--inline-source']
RDOC_FILES = ['README', "CHANGELOG", "COPYING","COPYING.LESSER", 'bin/craigwatch']
PKG_FILES = (%w(Rakefile) + RDOC_FILES + Dir.glob("{bin,test,lib}/**/*")).uniq.sort_by{|a,b| (a == 'lib/libcraigscrape.rb') ? -1 : 0 }

SPEC =
  Gem::Specification.new do |s|
    s.name = NAME
    s.version = VERS
    s.platform = Gem::Platform::RUBY
    s.has_rdoc = true
    s.bindir = 'bin'
    s.executables = 'craigwatch'
    s.rdoc_options += RDOC_OPTS
    s.extra_rdoc_files = RDOC_FILES
    s.summary = "quick, easy, craigslist parsing library that takes the monotony out of working with craigslist posts and listings"
    s.description = s.summary
    s.author = "Chris DeRose, DeRose Technologies, Inc."
    s.email = 'cderose@derosetechnologies.com'
    s.homepage = 'http://www.derosetechnologies.com/community/libcraigscrape'
    s.rubyforge_project = 'libcraigwatch'
    s.files = PKG_FILES
    s.require_paths = ["lib"] 
    s.test_files = FileList['test/test_*.rb']
  end

desc "Run all the tests"
Rake::TestTask.new do |t|
    t.libs << "test"
    t.test_files = FileList['test/test_*.rb']
    t.verbose = true
end

Rake::RDocTask.new do |rdoc|
    rdoc.rdoc_dir = 'doc/rdoc'
    rdoc.options += RDOC_OPTS
    rdoc.main = "README"
    # NOTE: If you don't put libcraigscrape.rb at the beginning, the rdoc ends up looking a little screwy
    rdoc.rdoc_files.add RDOC_FILES+Dir.glob('lib/*.rb').sort_by{|a,b| (a == 'lib/libcraigscrape.rb') ? -1 : 0 }
end

task "lib" do
  directory "lib"
end

task :install do
  sh %{rake package}
  sh %{sudo gem install pkg/#{NAME}-#{VERS}}
end

task :uninstall => [:clean] do
  sh %{sudo gem uninstall #{NAME}}
end


