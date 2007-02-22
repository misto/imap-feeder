require 'base64'

class Message

  attr_reader :title, :body, :time, :id, :from

  def initialize(params)
    @title = params[:title] || ""
    @from  = params[:from]  || ""
    @body  = params[:body]  || ""
    @id    = params[:id]    || 0
    @time  = params[:time]  || Time.now
  end
  
  def format
    return <<-EOF
Date: #{@time}
Subject: #{format_title}
From: #{@from}

#{@body}
EOF
  end
  
  private
  def format_title
    #what don't we need to escape? everything in 7 bit?
    if @title =~ /^[\w\s:-]+$/
      @title
    else
      "=?utf-8?b?#{Base64.encode64(@title).gsub(/\n/, '')}?="
    end
  end
end
