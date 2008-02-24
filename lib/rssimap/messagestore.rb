require 'yaml'

class MessageStore

  def initialize(file)
    @file = file
    @root = {}
    if File.exist? @file
      File.open(@file) do |f|
        @root = YAML.load(f) || {}
      end
    else
      $log.error "#{file} does not exist!"
    end
  end

  def add_new(folder, titles)
    @root[folder] ||= []
    @root[folder].unshift(*titles)
    @root[folder] = @root[folder].first(5)
  end
  
  def get_latest(folder)
    @root[folder] || []
  end
  
  def save
    File.open(@file, "w") do |f|
      YAML.dump(@root, f)
    end
  end  
end
