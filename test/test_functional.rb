$:.unshift File.expand_path(File.join(File.dirname(__FILE__), ".."))

require 'test/unit'

# The server tests needs to access an IMAP-Server with these following parameters.
# Do not use an account that already contains messages, they might get lost.
$host = ""
$user = ""
$pass = ""

require 'test/test_server'
