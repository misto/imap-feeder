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
      $log.info "Starting #{path}"

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

      latest = get_latest(path)
      messages = reader.get_newer_than(latest)

      unless messages.empty?
        $log.info "already processed messages: '#{latest.join("', '")}'"
        send_messages(messages, path)
    end

    $log.info "Finished"
  end

  private

  def send_messages messages, path
    $log.info "#{messages.size} new message(s)"
    messages.each do |msg|
      send_message(msg, path)
    end
    message_sent(messages, path)
    end
  end

  def message_sent(messages, path)
    titles = messages.collect do |msg|
      msg.generate_identifier
    end

    @store.add_new(path, titles)
    @store.save
  end

  def send_message(msg, complete_path)
    @server.send(msg, complete_path)
    $log.info "Found in #{complete_path.split(".").last}: #{msg.generate_identifier}"
  end

  def get_latest(path)
    @store.get_latest path
  end

  def create_folder(path)
    $log.info "Creating #{path}"
    @server.create_folder path
  end

  def check_folder_exists(path)
    @server.has_folder? path
  end
end
