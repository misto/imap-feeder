require 'log4r'

require 'lib/server'
require 'lib/message'
require 'lib/opmlreader'
require 'lib/feedreader'
require 'lib/messagestore'


$log = Log4r::Logger.new 'rssimap'
$log.outputters = Log4r::Outputter.stdout
$log.level = Log4r::DEBUG

class RssImap
  def initialize
    @server = Server.new :host => "misto.ch", :user => "rss", :pass => "for_imap"
    @root = OpmlReader.get File.new("/home/misto/feeds.opml")
    @store = MessageStore.new("processed_feeds.yaml")
  end

  def process(folder, parent_path)
    path = parent_path + folder.name
    
    create_folder(path) unless check_folder_exists(path)
    
    if folder.class == FeedUrl
      last = get_last(path)
      messages = get_new_messages(folder, last)
      unless messages.empty?
        messages.each do |msg|
          send_message(msg, path)
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
    $log.info "Found new: #{msg.title}"
  end
  
  def get_new_messages(folder, last)
    $log.debug "last message was #{last}"
    begin
      messages = FeedReader.new(folder.url).get_newer_than(last)[0..3]
    rescue FeedTools::FeedAccessError
      $log.warn "Timeout while receiving #{folder.name} (#{folder.url})"
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
  RssImap.new.go
end
