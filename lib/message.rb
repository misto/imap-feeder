require 'base64'
require 'action_mailer'
require 'hpricot'
require 'htmlentities'

$KCODE="U"

class Message

  include ActionMailer::Quoting

  attr_reader :title, :body, :time, :id, :from

  def initialize(params)
    @title = HTMLEntities.decode_entities(params[:title] || "")
    @from  = params[:from]
    @body  = strip_html(params[:body] || params[:url] || "")
    @id    = params[:id] || 0
    @time  = params[:time] || Time.now
    @url   = params[:url]
  end
  
  def format
    return <<-EOF
Date: #{@time.strftime("%a %b %d %H:%M:%S %z %Y")}
Subject: #{quote_if_necessary(@title, "UTF-8")}
From: #{quote_if_necessary((@from || "Unknown") + " <spam@example.org>", "UTF-8")}
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
    body.gsub!(/\n{3,}/, "\n\n")
    
    HTMLEntities.decode_entities(body.strip)
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
