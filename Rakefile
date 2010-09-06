require 'rake'
require 'rake/clean'
require 'rake/gempackagetask'
require 'rake/rdoctask'
require 'rake/testtask'
require 'fileutils'
require 'tempfile'

include FileUtils

RbConfig = Config unless defined? RbConfig

NAME = "libcraigscrape"
VERS = ENV['VERSION'] || "0.8.4"
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
    s.add_dependency 'hpricot'
    s.add_dependency 'htmlentities'
    s.add_dependency 'activesupport'
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

Rake::GemPackageTask.new(SPEC) do |p|
  p.need_tar = false
  p.need_tar_gz = true
  p.need_tar_bz2 = true
  p.need_zip = true
  p.gem_spec = SPEC
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

require 'roodi'
require 'roodi_task'

namespace :code_tests do
  desc "Analyze for code complexity"
  task :flog do
    require 'flog'

    flog = Flog.new
    flog.flog_files ['lib']
    threshold = 105
  
    bad_methods = flog.totals.select do |name, score|
       score > threshold
    end
  
    bad_methods.sort { |a,b| a[1] <=> b[1] }.each do |name, score|
      puts "%8.1f: %s" % [score, name]
    end
  
    puts "WARNING : #{bad_methods.size} methods have a flog complexity > #{threshold}" unless bad_methods.empty?
  end
  
  desc "Analyze for code duplication"
    require 'flay'
    task :flay do
    threshold = 25
    flay = Flay.new({:fuzzy => false, :verbose => false, :mass => threshold})
    flay.process(*Flay.expand_dirs_to_files(['lib']))
  
    flay.report
  
    raise "#{flay.masses.size} chunks of code have a duplicate mass > #{threshold}" unless flay.masses.empty?
  end
  
  RoodiTask.new 'roodi', ['lib/*.rb'], 'roodi.yml'
end

desc "Run all code tests"
task :code_tests => %w(code_tests:flog code_tests:flay code_tests:roodi)

