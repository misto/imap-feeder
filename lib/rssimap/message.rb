require 'base64'
require 'time'
require 'action_mailer'
require 'hpricot'
require 'tidy'
require 'htmlentities'
require 'digest/md5'

$KCODE="U"

class Message

  include ActionMailer::Quoting

  def initialize(params)
    @params = params
  end

  def title
    @title ||= (dec(@params[:title]) || "")
  end

  def from
    @from ||= (dec(@params[:from]) || "Unknown <spam@example.org>")
  end

  def body
    @body ||= strip_html(@params[:body] || @params[:url] || "")
  end

  def time
    @time ||= (@params[:time] || Time.now.localtime).rfc2822
  end

  def quote(str)
    return "" if not str
    str.gsub(/[^a-zA-Z0-9 -_:,\.]+/) {|to_quote| quote_if_necessary(to_quote, "UTF-8")}
  end

  def generate_identifier
    @cached_identifier ||= "#{@params[:title]}##{Digest::MD5.hexdigest(body())}"
  end

  def format
    url   = @params[:url]
    return <<-EOF
Date: #{time}
Subject: #{quote(title)}
From: #{quote(from)}
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 8bit

#{body}#{"\n\n" + url if url}
EOF
  end

  private

  def replace(doc, element)
    doc.search(element) do |found|
      replacement = block_given? ? yield(found) : found.innerHTML
      found.swap(replacement)
    end
  end

  def tidy(body)

    begin
      Tidy.path = $tidy_path unless Tidy.path
    rescue LoadError => e
      $log.warning "Tidy not available: #{e.message}"
      return body
    end

    tidy_html = Tidy.open(:show_warnings => true) do |tidy|
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

  def dec(html)
    HTMLEntities.decode_entities(html).strip if html
  end

  def strip_html(body)

    doc = Hpricot(tidy(dec(body)))

    replace(doc, 'p')      {|paragraph| "\n#{paragraph.innerHTML}\n"}
    replace(doc, 'strong') {|strong| "*#{strong.innerHTML}*"}
    replace(doc, 'b')      {|bold| "*#{bold.innerHTML}*"}
    replace(doc, 'em')     {|em| "*#{em.innerHTML}*"}
    replace(doc, 'li')     {|li| "- #{li.innerHTML}"}
    replace(doc, 'i')
    replace(doc, 'ol')
    replace(doc, 'ul')
    replace(doc, 'abr')
    replace(doc, 'font')
    replace(doc, 'span')
    replace(doc, 'div')
    replace(doc, 'br')     {|br| "\n"}
    replace(doc, 'img')    {|img| img.attributes['alt'] || ""}
    replace(doc, 'abbr')   {|abbr| abbr.innerHTML + (" (#{abbr.attributes['title']})" || "")}

    urls = gather_urls(doc)

    body = doc.to_html

    unless urls.empty?
      body << "\n"
      max_length = "[0]".length + Math.log10(urls.size).floor + 1
      urls.each_with_index do |url, i|
        index = i + 1
        str = "\n[#{index}]".ljust max_length
        body << "#{str} #{url}"
      end
    end

    doc = Hpricot(body)
    replace(doc, 'a')
    body = doc.to_html

    #sanitize newlines
    body.gsub!(/(\n\s*){3,}/, "\n\n")

    dec(body)
  end

  def gather_urls(doc)
    urls = []
    doc.search('a') do |link|
      href = URI(link.attributes['href']) rescue nil
      next if not href && href.host
      next if link.innerHTML.strip == href.to_s.strip
      urls << href
      link.swap(link.innerHTML.strip + "[#{urls.length}]")
    end
    urls
  end
end
