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
    log_time_with_message "Started"
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
        rescue OpenURI::HTTPError => e
          $log.warn "Error retrieving #{url}: #{e.message}"
        rescue Exception => e
          $log.error "Unexpected error while retrieving #{path}: #{e.message}"
        end
      end
    end

    threads.each do |thread|

      thread.join

      next if not thread[:reader]
      messages = thread[:reader].get_newer_than(thread[:last]).first(10)
      $log.debug "last message was #{thread[:last].join("\n")}" if not messages.empty?
      $log.debug "#{messages.size} new messages" if not messages.empty?

      if not messages.empty?
        messages.each do |msg|
          send_message(msg, thread[:path])
        end
        message_sent(messages, thread[:path])
      end
    end

    log_time_with_message "Finished"
  end


  private

  def log_time_with_message message
    $log.info "#{message} #{Time.now.strftime "%Y.%m.%d %H:%M"}"
  end

  
  def message_sent(messages, path)
    @store.add_new(path, messages.first(5).collect{|msg| msg.title })
    @store.save
  end
  
  def send_message msg, complete_path
    @server.send(msg, complete_path)
    $log.info "Found in #{complete_path.split(".").last}: #{msg.title}"
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
