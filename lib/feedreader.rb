require 'open-uri'
require 'feed_tools'
require 'htmlentities'
require 'tidy'

Tidy.path = "/usr/lib/libtidy.so"

$KCODE="U"

class FeedReader
  attr_reader :messages
  def initialize(feed_url)
    @feed = FeedTools::Feed.open(feed_url, :entry_sorting_property => "time")
  end

  def dec str
    #feedtools decode? reduce dependency
    HTMLEntities.decode_entities(str) if str
  end

  # we only compare \w\d characters to avoid problems 
  # with special chars and different encodings
  def equal(left, right)
    if left and right
      left.gsub(/[^A-Za-z0-9]/, '') == right.gsub(/[^A-Za-z0-9]/, '') 
    else
      false
    end
  end

  def tidy body
    tidy_html = Tidy.open(:show_warnings=>true) do |tidy|
      tidy.options.markup = true
      tidy.options.wrap = 0
      tidy.options.logical_emphasis = true
      tidy.options.drop_font_tags = true
      tidy.options.output_encoding = "utf8"
      tidy.options.input_encoding = "utf8"
      tidy.options.doctype = "omit"
      tidy.clean(body)
    end
    tidy_html.strip!
    tidy_html.gsub!(/^<html>(.|\n)*<body>/, "")
    tidy_html.gsub!(/<\/body>(.|\n)*<\/html>$/, "")
    tidy_html.gsub!("\t", "  ")
    tidy_html
  end

  def get_newer_than(title)
    messages = []
    @feed.items.each do |item|
      break if equal(dec(item.title), title)

      messages << Message.new(
        :title => dec(item.title),
        :time => item.published,
        :body => dec(tidy(item.description)),
        :from => dec(item.author && item.author.name),
        :url => item.link)
    end
    messages
  end
end
