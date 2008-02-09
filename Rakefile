require 'rubygems'
Gem::manage_gems
require 'rake/gempackagetask'
require 'rake/testtask'
require 'rake/rdoctask'

version="0.1.0"

file "pkg/rssimap-#{version}.gem" => [:prepare_gem]

task :default => ["gem"]

spec = Gem::Specification.new do |s|
  s.name	= "rss-imap"
  s.version	= version
  s.author	= "Mirko Stocker"
  s.email	= "me@misto.ch"
  s.homepage	= ""
  s.platform	= Gem::Platform::RUBY
  s.summary	= "RssImap publishes your favorite feeds to an IMAP server."
  s.files	= Dir.glob("{test,lib}/**/*") + ["README", "COPYING", "settings.rb.example"]
  s.require_path = "lib"

  s.add_dependency('actionmailer', '>= 1.3.2')
  s.add_dependency('hpricot',      '>= 0.5')
  s.add_dependency('htmlentities', '>= 3.0.1')
  s.add_dependency('tidy',         '>= 1.1.2')
  s.add_dependency('simple-rss',   '>= 1.1')

  s.has_rdoc = true
  s.executables	= "rssimap"
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_tar = true
end

Rake::TestTask.new do |t|
  t.test_files = FileList['test/test_unit.rb']
  t.verbose = true
end

Rake::RDocTask.new("rdoc") { |rdoc|
  rdoc.rdoc_dir = 'doc'
  rdoc.title    = spec.name
  rdoc.options << '--line-numbers' << '--inline-source' <<
    '--main' << 'README' <<
    '--title' <<  spec.name 
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
}

