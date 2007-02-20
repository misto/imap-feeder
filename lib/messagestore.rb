class MessageStore

  def initialize(file)
    @file = file
    if File.exists? @file
      File.open(@file, "r") do |f|
        @root = YAML.load(f)
      end
    else
      @root = {}
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