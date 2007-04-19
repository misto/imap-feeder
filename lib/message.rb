require 'base64'
require 'action_mailer'
require 'hpricot'
require 'tidy'
require 'htmlentities'


$KCODE="U"

class Message

  include ActionMailer::Quoting

  attr_reader :title, :body, :time, :id, :from

  def initialize(params)
    @title = dec(params[:title]) || ""
    @from  = dec(params[:from])
    @body  = strip_html(params[:body] || params[:url] || "")
    @id    = params[:id] || 0
    @time  = params[:time] || Time.now.gmtime
    @url   = params[:url]
  end

  #
  # Quote characters in the string using ActionMailer's quote_if_necessary.
  #
  def quote(str)
    all_ascii = -1
    str.split("").each do |char|
      if(char[0].to_i > 31 && char[0].to_i < 127)
        all_ascii += 1
      else
        break
      end
    end
    (all_ascii > -1 ? str[0..all_ascii] : "")  + quote_if_necessary(str[all_ascii + 1..-1], "UTF-8")
  end
  
  def format
    return <<-EOF
Date: #{@time.strftime("%a %b %d %H:%M:%S %z %Y")}
Subject: #{quote(@title)}
From: #{quote((@from || "Unknown <spam@example.org>"))}
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 8bit

#{@body}#{"\n\n" + @url if @url}
EOF
  end
  
  private
  
  def replace(doc, element)
    doc.search(element) do |found|
      found.swap( block_given? ? yield(found) : found.innerHTML)
    end
  end
  
  def tidy body

    begin
      Tidy.path = $tidy_path unless Tidy.path
    rescue LoadError => e
      $log.warning "Tidy not available: #{e.message}"
      return body
    end

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

  def dec html
    HTMLEntities.decode_entities(html).strip if html
  end

  def strip_html(body)

    body = dec(body)
    body = tidy(body)
    doc = Hpricot(body)
    
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
    replace(doc, 'br')     {|br| "\n"}
    replace(doc, 'img')    {|img| img.attributes['alt'] || ""}
    replace(doc, 'abbr')   {|abbr| abbr.innerHTML + (" (#{abbr.attributes['title']})" || "")}

    urls = gather_urls(doc)

    body = doc.to_html
         
    unless urls.empty?
      body << "\n"
      urls.each_with_index do |url, i|
        body << "\n[#{i + 1}] #{url}"
      end
    end

    doc = Hpricot(body)
    replace(doc, 'a')
    body = doc.to_html
    
    #sanitize newlines
    body.gsub!(/(\n\s*){3,}/, "\n\n")

    dec(body)
  end
  
  def gather_urls doc
    urls = []
    doc.search('a') do |link|
      href = URI link.attributes['href'] rescue nil
      next if not href && href.host
      next if link.innerHTML.strip == href.to_s.strip
      urls << href
      link.swap link.innerHTML.strip + "[#{urls.length}]"
    end
    urls
  end
  
end
