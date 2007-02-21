require 'log4r'

require 'lib/server'
require 'lib/message'
require 'lib/opmlreader'
require 'lib/feedreader'
require 'lib/messagestore'

include Log4r
$log = Logger.new 'rssimap'
$log.outputters = Outputter.stdout
$log.level = DEBUG

class RssImap
  def initialize
    @server = Server.new :host => "misto.ch", :user => "rss", :pass => "qaysedc"
    @root = OpmlReader.get File.new("/home/misto/feeds.opml")
    @store = MessageStore.new("processed_feeds.yaml")
  end

  def process(folder, parent_path)
    path = parent_path + folder.name
    $log.debug "Checking #{path}"
    
    unless check_for_folder(path)
      $log.info "Creating #{path}"
      create_folder(path)
    end
    
    if folder.class == FeedUrl
      last = get_last(path)
      $log.debug "last message was #{last}"
      
      messages = get_new_messages(folder, last)
      $log.debug "new messages: #{messages.inspect}"
      
      unless messages.empty?
        messages.each do |msg|
          send_message(msg, path)
          $log.info "Found new: #{msg.title}"
        end
        messages_sent(path, messages)
      end
      return
    end
    
    (folder.children + folder.urls).each do |child|
      process(child, path + '.')
    end  
  end
    
  def go
    $log.info "Starting"
    process(@root, "INBOX")
    $log.info "Finished"
    @store.save
  end
  
  private
  
  def messages_sent(path, messages)
    @store.add_new(path, messages.first.title)
  end
  
  def send_message msg, complete_path
    @server.send(msg, complete_path)
  end
  
  def get_new_messages(folder, last)
    FeedReader.new(folder.url).get_newer_than(last)[0..3]
  end
  
  def get_last path
    @store.get_latest path
  end
  
  def create_folder path
    @server.create_folder path
  end
  
  def check_for_folder path
    @server.has_folder? path
  end

end

RssImap.new.go
