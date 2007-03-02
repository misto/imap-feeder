$:.unshift File.expand_path(File.join(File.dirname(__FILE__), ".."))

require 'log4r'
require 'yaml'
require 'uri'
require 'net/http'

require 'lib/opmlreader'

class RssImapConfig
  def self.create(opml_file, output)
    items = process(OpmlReader.get(opml_file), "INBOX").flatten
    YAML.dump(items, output)
  end

  def self.check(configuration)
    YAML.load(configuration).each do |conf_item|
      check_url_connection(conf_item['feed']['url'])
      check_path_name(conf_item['feed']['path'])
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
  
  def self.check_url_connection(url)
    begin
      uri = URI.parse url
      uri.path = "/" if uri.path.empty?
      
      response = Net::HTTP.new(uri.host, uri.port).head(uri.path, nil)
      if response.code =~ /^[45]\d/
        $log.warn "Problem connecting to #{url}: #{response.message}"
      end
    rescue Exception => e
      $log.warn "Exception while connecting to #{url}: #{e}."
    end
  end
  
  def self.check_path_name(path)
    path.scan(/[^#{IMAP_CHARS}\.]+/) do |char|
      $log.error "Invalid character found in \'#{path}\': #{char}"
    end
  end
end
