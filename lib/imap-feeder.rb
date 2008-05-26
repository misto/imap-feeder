$:.unshift File.dirname(__FILE__)

require 'imap-feeder/server'
require 'imap-feeder/message'
require 'imap-feeder/feedreader'
require 'imap-feeder/messagestore'

$KCODE="U"

class ImapFeeder

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
        send_messages(messages, path, reader.number_of_entries)
      end
    end

    $log.info "Finished"
  end

  private

  def send_messages messages, path, number_of_entries
    $log.info "#{messages.size} new message(s)"
    messages.each do |msg|
      send_message(msg, path)
    end
    message_sent(messages, path, number_of_entries)
  end

  def message_sent(messages, path, number_of_entries)
    identifiers = messages.collect do |msg|
      msg.generate_identifier
    end

    @store.add_new(path, identifiers, number_of_entries)
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
