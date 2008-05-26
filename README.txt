= imap-feeder

imap-feeder checks your favorite RSS and Atom feeds and stores new entries
on your IMAP server, so you can read it with your favorite mail reader
or even a webmail client.

== Prerequisites

To use this software, you'll need a system to run the script in a certain
interval and a compatible IMAP account.

=== Dependencies

imap-feeder needs the following gems, if they are not already present on your system,
they'll get installed:
- actionmailer
- hpricot
- htmlentities
- tidy
- simple-rss

The tidy gem doesn't contain libtidy, you need to install it separately using
your package manager. Depending on your system, this can be done like:
- Gentoo: emerge app-text/htmltidy
- Debian: aptitude install libtidy-ruby

=== Compatible IMAP Servers

I use imap-feeder with Courier-IMAP and Dovecot. Other IMAP servers should
work as well, but I haven't tested them. If you can run it successfully with
another server, please drop me a note so I can update this README.

== Installation

You may get the latest stable version from Rubyforge:

  $ gem install imap-feeder

After that, you should have the gem installed and you can copy the
settings.rb.example file from the installation directory to the place from
where you want to run the script. You'll need a configuration file, another
one to hold a list of all your feeds' urls and a temporary file to hold
state information about the processed feeds.

Please edit the settings-file accordingly to the instructions in it. You have to
change at least the imap connection strings and the directory.

Next we need a list of all the urls of the blogs you want imap-feeder to check. Run
imap-feeder -n to create an empty file or with the name of an OPML file as argument.
For example, the following creates the "feeds.yml" file with all the feeds from
"feeds.opml" and uses the "feeds" folder as root in your inbox to store them
all. Each feed will get its own folder under the "feeds" root. (If you just want to
evaluate imap-feeder, I'd recommend to operate it on a dedicated mailbox, so you can
easily get rid of it afterwards.)

  $ imap-feeder -n feeds.opml -o -r feeds

You might want to edit the file afterwards to rename the folders. You can run
imap-feeder -c feeds.yaml to check the configuration. After that, we can run
imap-feeder with the settings.rb file as argument.

  $ imap-feeder ~/.imap-feeder/settings.rb

I recommend to use absolute paths to avoid trouble. If everything works,
the script should generate some folders on your IMAP server and fetch the
first round of feeds. If you are happy with the results, you can run the
script regularly, for example using cron.

Thank you for using imap-feeder and don't forget to drop me an email if you
have feature requests or bugs to report.
