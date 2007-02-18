require 'base64'

class Message

  attr_reader :title, :body, :time, :id

  def initialize(params)
    @title = params[:title] || ""
    @body = params[:body] || "[body]"
    @id = params[:id] || 0
    @time = params[:time] || Time.now
  end
  
  def format
    return <<-EOF
Date: #{@time}
Subject: =?utf-8?b?#{Base64.encode64(@title).gsub(/\n/, '')}?=
From:
To:

#{@body}
EOF
  end
end
  