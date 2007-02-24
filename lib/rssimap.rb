require 'log4r'

require 'lib/server'
require 'lib/message'
require 'lib/feedreader'
require 'lib/messagestore'

class RssImap
  def initialize(server, store, config)
    @server = server
    @store = store
    @config = config
  end

  def run
    $log.info "Starting"
    feeds = YAML.load(@config)

    feeds.each do |feed|
      url = feed['feed']['url']
      path = feed['feed']['path']

      create_folder(path) unless check_folder_exists(path)
      last = get_last(path)
      messages = get_new_messages(url, last)
      unless messages.empty?
        messages.each do |msg|
          send_message(msg, path)
        end
        messages_sent(path, messages)
      end
    end
    $log.info "Finished"
    @store.save
  end
  
  private
  
  def messages_sent(path, messages)
    @store.add_new(path, messages.first.title)
  end
  
  def send_message msg, complete_path
    @server.send(msg, complete_path)
    $log.info "Found new: #{msg.title}"
  end
  
  def get_new_messages(url, last)
    $log.debug "last message was #{last}"
    begin
      messages = FeedReader.new(url).get_newer_than(last)[0..3]
    rescue FeedTools::FeedAccessError
      $log.warn "Timeout while receiving #{url}"
      return []
    end
    $log.debug "#{messages.size} new messages"
    messages
  end
  
  def get_last path
    @store.get_latest path
  end
  
  def create_folder path
    $log.info "Creating #{path}"
    @server.create_folder path
  end
  
  def check_folder_exists path
    $log.debug "Checking #{path}"
    @server.has_folder? path
  end
end

if __FILE__ == $0
  $log = Log4r::Logger.new 'rssimap'
  $log.outputters = Log4r::Outputter.stdout
  $log.level = Log4r::DEBUG

  server = Server.new :host => "misto.ch", :user => "rss", :pass => "for_imap"
  store = MessageStore.new("processed_feeds.yaml")
  config = ARGF
  RssImap.new(server, store, config).run
end
