require 'optparse'
require 'ostruct'

class CreateConfigParser
  def self.parse(args)
    options = OpenStruct.new

    opts = OptionParser.new do |opts|
      opts.banner = <<EOF
Usage: #{$0} [options] to create or check your configuration
or     #{$0} SETTINGS_FILE to run the script
EOF

      opts.on("-c", "--check-settings SETTINGS_FILE",
              "Check an existing configuration") do |file|
        options.check = file
      end

      opts.on("-r", "--imap-root [FOLDER]",
              "Use this as the root folder for all feeds") do |folder|
        options.folder = folder
      end

      opts.on("-n", "--new-config [OPML_FILE]",
              "Create a new configuration") do |file|
        options.create = true
        options.create_file = file
      end

      opts.on("-p", "--pretend",
              "Don't do anything, just pretend. " +
              "Prints new items to the console.") do |pretend|
        options.pretend = pretend
      end
    end
    opts.parse!(args)

    options
  end
end
