require 'yaml'

class MessageStore

  def initialize(file)
    @file = file
    @root = {}
    if File.exists? @file
      File.open(@file) do |f|
        @root = YAML.load(f)
      end
    end
  end
  
  def add_new(folder, title)
    @root[folder] = title
  end
  
  def get_latest(folder)
    @root[folder] || ""
  end
  
  def save
    File.open(@file, "w") do |f|
      YAML.dump(@root, f)
    end
  end  
end