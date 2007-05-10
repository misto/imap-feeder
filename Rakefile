require 'rubygems'
Gem::manage_gems
require 'rake/gempackagetask'

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
  s.summary	= "RssImap publishes your favorite feeds to an IMAP server so you can read them with your mail program."
  candidates	= Dir.glob("{test,lib}/**/*") + ["README", "COPYING", "settings.rb.example"]
  s.files	= candidates.delete_if do |item|
  			item.include?(".svn")
		  end

  s.add_dependency('actionmailer', '>= 1.3.2')
  s.add_dependency('hpricot',      '>= 0.5')
  s.add_dependency('htmlentities', '>= 3.0.1')
  s.add_dependency('tidy',         '>= 1.1.2')
  s.add_dependency('simple-rss',   '>= 1.1')

  s.has_rdoc	= false
  s.executables	= "rssimap"
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_tar = true
end
