require 'log4r'

require 'lib/server'
require 'lib/message'
require 'lib/feedreader'
require 'lib/messagestore'

$KCODE="U"

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
      path = feed['feed']['path']
      create_folder(path) unless check_folder_exists(path)
    end

    threads = []

    feeds.each do |feed|
      threads << Thread.new(feed) do |feed_to_fetch|
        url  = feed_to_fetch['feed']['url']
        path = feed_to_fetch['feed']['path']
        Thread.current[:path] = path
        Thread.current[:last] = get_last(path)
        begin
          Thread.current[:reader] = FeedReader.new(url)
        rescue FeedTools::FeedAccessError => e
          $log.warn "Error retrieving #{url}: #{e.message}"
        end
      end
    end

    threads.each {|t| t.join }

    threads.each do |thread|
      next if not thread[:reader]
      messages = thread[:reader].get_newer_than(thread[:last])[0..3]
      $log.debug "last message was #{thread[:last]}" if messages.size > 0
      $log.debug "#{messages.size} new messages" if messages.size > 0

      if not messages.empty?
        messages.each do |msg|
          send_message(msg, thread[:path])
        end
        messages_sent(messages.first, thread[:path])
      end
    end

    $log.info "Finished"
  end
  
  private
  
  def messages_sent(message, path)
    @store.add_new(path, message.title)
    @store.save
  end
  
  def send_message msg, complete_path
    @server.send(msg, complete_path)
    $log.info "Found new: #{msg.title}"
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
