require 'optparse'
require 'ostruct'

class CreateConfigParser
  def self.parse(args)
    options = OpenStruct.new

    opts = OptionParser.new do |opts|
      opts.banner = "Usage: #{$0} [options]"
  
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
    
    unless options.check or options.create
      $stderr.print <<EOS
You must specify one of the `-cn' options
Try `tar --help' for more information.
EOS
      exit 1
    end

    options
  end
end