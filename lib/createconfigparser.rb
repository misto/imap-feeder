require 'optparse'
require 'ostruct'

class CreateConfigParser
  def self.parse(args)
    options = OpenStruct.new

    opts = OptionParser.new do |opts|
      opts.banner = <<EOF
Usage: #{$0} [options] to create or check your configuration
or     #{$0} CONFIG_FILE to run the script
EOF
  
      opts.on("-c", "--check-config CONFIG_FILE", "Check an existing configuration") do |file|
        options.check = file
      end  
  
      opts.on("-n", "--new-config [OPML_FILE] [ROOT_FOLDER]", "Create a new configuration") do |file, folder|
        options.create = true
        options.create_file = file
        options.folder = folder || "INBOX"
      end
  
      opts.on("-o", "--output [CONFIG_FILE]", "The location of the generated file") do |file|
        options.out = file
      end
    end
    opts.parse!(args)
    
    options
  end
end
