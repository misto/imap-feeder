require 'rssimap/server'
require 'rssimap/message'
require 'rssimap/feedreader'
require 'rssimap/messagestore'

$KCODE="U"

class RssImap

  def initialize(server, store, config)
    @server = server
    @store = store
    @config = config
  end

  def run
    $log.info "Started"
    feeds = YAML.load(@config)

    feeds.each do |feed|
      path = feed['feed']['path']
      latest = get_latest(path)

      create_folder(path) unless check_folder_exists(path)

      begin
        url  = feed['feed']['url']
        reader = FeedReader.new(url)
      rescue OpenURI::HTTPError => e
        $log.warn "Error retrieving #{url}: #{e.message}"
	next
      rescue Exception => e
        $log.error "Unexpected error while retrieving #{path}: #{e.message}"
	next
      end

      $log.info "Starting #{path}"
      messages = reader.get_newer_than(latest).first(10)

      unless messages.empty?
        $log.info "latest messages were: '#{latest.join("', '")}'"
        $log.info "#{messages.size} new messages"

        messages.each do |msg|
          send_message(msg, path)
        end
        message_sent(messages, path)
      end
    end

    $log.info "Finished"
  end

  private

  def message_sent(messages, path)
    titles = messages.collect{ |msg| msg.title }
    @store.add_new(path, titles)
    @store.save
  end

  def send_message(msg, complete_path)
    @server.send(msg, complete_path)
    $log.info "Found in #{complete_path.split(".").last}: #{msg.title}"
  end

  def get_latest(path)
    @store.get_latest path
  end

  def create_folder(path)
    $log.info "Creating #{path}"
    @server.create_folder path
  end

  def check_folder_exists(path)
    $log.debug "Checking #{path}"
    @server.has_folder? path
  end
end
