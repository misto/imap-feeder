require 'yaml'
require 'uri'
require 'net/http'
require 'ftools'

require 'imap-feeder/opmlreader'

class ImapFeederConfig
  def self.create(opml_file, root_folder)

    root_folder = root_folder ? "INBOX.#{root_folder}" : "INBOX"

    if opml_file
      items = process(OpmlReader.get(File.open(opml_file)), "#{root_folder}").flatten
    else
      items = [
        {"feed" => {"url" => "http://rubyforge.org/export/rss_sfnews.php",    "path" => "#{root_folder}.rubyforge"}},
        {"feed" => {"url" => "http://feeds.feedburner.com/DilbertDailyStrip", "path" => "#{root_folder}.dilbert"}}
      ]
    end

    File.open("#{Dir.pwd}/feeds.yml", "w+") do |file|
      YAML.dump(items, file)
    end

    File.copy "#{File.dirname(__FILE__)}/../../settings.rb.example", "#{Dir.pwd}/settings.rb"
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
      if response.code =~ /^[^2]\d/
        $log.info "Connecting to #{url}: #{response.message}, code: #{response.code}"
      else
        $log.info "Connecting to #{url}: OK"
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
