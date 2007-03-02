$log = Log4r::Logger.new 'rssimap'

#
# The outputter to be used for logging. Take a look at 
# http://log4r.sourceforge.net/rdoc/files/log4r/outputter/outputter_rb.html
# for more configuration options.
#
$log.outputters = Log4r::Outputter.stdout

#
# The level can be set to: DEBUG < INFO < WARN < ERROR < FATAL
# 
$log.level = Log4r::DEBUG

#
# IMAP connection settings. You shouldn't use an existing account 
# because the script might overwrite existing emails.
#
$host = "misto.ch"
$user = "rss"
$pass = "for_imap"

#
# RssImap needs a file to store the last message for each feed 
# so it doesn't fetch old entries. Where should that file be?
#
$temp = "processed_feeds.yaml"

#
# The configuration file that was generated using rssimapconfig.rb
#
$config = ARGV.first || "feeds.yml"
