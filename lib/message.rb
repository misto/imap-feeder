require 'base64'
require 'action_mailer'
require 'hpricot'

$KCODE="U"

class Message

  include ActionMailer::Quoting

  attr_reader :title, :body, :time, :id, :from

  def initialize(params)
    @title = params[:title] || ""
    @from  = params[:from]
    @body  = strip_html(params[:body] || params[:url] || "")
    @id    = params[:id] || 0
    @time  = params[:time] || Time.now
    @url   = params[:url]
  end

  #
  # Quote characters in the string using ActionMailer's quote_if_necessary.
  #
  def quote(str)
    str =~ /([\w\d ]*)(.*)/
    $1 + quote_if_necessary($2, "UTF-8")
  end
  
  # FIXME: @body.unpack("C*").pack("U*") ?
  def format
    return <<-EOF
Date: #{@time.strftime("%a %b %d %H:%M:%S %z %Y")}
Subject: #{quote(@title)}
From: #{quote((@from || "Unknown") + " <spam@example.org>")}
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
  
  def strip_html(body)

    doc = Hpricot(body)
    
    replace(doc, 'p')      {|paragraph| "\n#{paragraph.innerHTML}\n"}
    replace(doc, 'strong') {|strong| "*#{strong.innerHTML}*"}
    replace(doc, 'b')      {|bold| "*#{bold.innerHTML}*"}
    replace(doc, 'em')     {|em| "*#{em.innerHTML}*"}
    replace(doc, 'i')
    replace(doc, 'abr')
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
    body.strip
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
