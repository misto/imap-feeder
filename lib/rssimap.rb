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
      $log.info "Processing #{path}"

      create_folder(path) unless check_folder_exists(path)

      begin
        url = feed['feed']['url']
        reader = FeedReader.new(url)
      rescue OpenURI::HTTPError => e
        $log.warn "Error retrieving #{url}: #{e.message}"
        next
      rescue Exception => e
        $log.error "Unexpected error while retrieving #{path}: #{e.message}"
        next
      end

      archive = get_archived(path)
      messages = reader.get_new(archive)

      unless messages.empty?
        $log.debug "already processed messages: '#{archive.join("', '")}'"
        send_messages(messages, path)
      end
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

  def message_sent(messages, path)
    identifiers = messages.collect do |msg|
      msg.generate_identifier
    end

    @store.add_new(path, identifiers)
    @store.save
  end

  def send_message(msg, complete_path)
    @server.send(msg, complete_path)
    $log.info "Found in #{complete_path.split(".").last}: #{msg.generate_identifier}"
  end

  def get_archived(path)
    @store.get_archived path
  end

  def create_folder(path)
    $log.info "Creating #{path}"
    @server.create_folder path
  end

  def check_folder_exists(path)
    @server.has_folder? path
  end
end
