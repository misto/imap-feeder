require 'yaml'

class MessageStore

  MESSAGES_TO_STORE = 100

  def initialize(file)
    @file = file
    @root = {}
    if File.exist? @file
      File.open(@file) do |f|
        @root = YAML.load(f) || {}
      end
    else
      $log.warn "#{file} does not exist, creating a new one."
    end
  end

  def add_new(folder, titles, number_of_entries = MESSAGES_TO_STORE)
    @root[folder] ||= []
    @root[folder].unshift(*titles)
    @root[folder].slice!((number_of_entries * 10)..-1)
    @root[folder].compact!
  end

  def get_archived(folder)
    @root[folder] || []
  end

  def save
    File.open(@file, "w") do |f|
      YAML.dump(@root, f)
    end
  end
end
