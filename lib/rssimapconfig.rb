require 'log4r'
require 'yaml'
require 'uri'
require 'net/http'

require 'lib/opmlreader'
require 'lib/createconfigparser'

class RssImapConfig
  def self.create(opml_file, output)
    items = process(OpmlReader.get(opml_file), "INBOX").flatten
    YAML.dump(items, output)
  end

  def self.check(file)
    YAML.load(file).each do |feed_item|
      check_url_connection(feed_item)
      check_path_name(feed_item)
    end
  end
   
  private
  def self.process(folder, parent_path)
    items = []
    path = parent_path + folder.name
      
    folder.urls.each do |child|
      feed_path = "#{path}.#{child.name}"
      $log.debug "#{feed_path}: #{child.url}"
      items << {"feed" => {"url" => child.url, "path" => feed_path}}
    end
  
    folder.children.each do |child|
      items << process(child, path + '.')
    end
    items
  end
  
  def self.check_url_connection(feed_item)
    begin
      url = feed_item['feed']['url']
      uri = URI.parse url
      response = Net::HTTP.new(uri.host, uri.port).head(uri.path == "" ? "/" : uri.path, nil)
      if response.code =~ /^[45]\d/
        $log.warn "Problem connecting to #{url}: #{response.message}"
      end
    rescue Exception => e
      $log.warn "Exception while connecting to #{url}: #{e}."
    end
  end
  
  def self.check_path_name(feed_item)
    path = feed_item['feed']['path']
    path.scan(/[^\w:,\-= \.]+/) do |char|
      $log.error "Invalid character found in \'#{path}\': #{char}"
    end
  end
end

if __FILE__ == $0
  $log = Log4r::Logger.new 'config'
  $log.outputters = Log4r::Outputter.stdout
  $log.level = Log4r::DEBUG

  opts = CreateConfigParser.parse(ARGV)
  
  if opts.create
    $log.info "Creating new configuration from #{opts.create}"
    RssImapConfig.create(File.open(opts.create), opts.out ? File.open( opts.out, "w") : $stdout)
  elsif opts.check
    $log.info "Checking configuration #{opts.check}"
    RssImapConfig.check(File.open(opts.check))
  end
end
