require 'optparse'
require 'ostruct'

class CreateConfigParser
  def self.parse(args)
    options = OpenStruct.new

    opts = OptionParser.new do |opts|
      opts.banner = <<EOF
Usage: #{$0} [options] to create or check your configuration
or     #{$0} to run the script
EOF
  
      opts.on("-c", "--check-config CONFIG_FILE", "Check an existing configuration") do |file|
        options.check = file
      end  
  
      opts.on("-n", "--new-config OPML_FILE", "Create a new configuration") do |file|
        options.create = file
      end
  
      opts.on("-o", "--output [CONFIG_FILE]", "The location of the generated file") do |file|
        options.out = file
      end
    end
    opts.parse!(args)
    
    options
  end
end