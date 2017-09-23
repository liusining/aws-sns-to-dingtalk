require 'sinatra'
require 'json'
require 'sinatra/json'
require 'sinatra/reloader' if development?
require 'rest-client'
require_relative 'env.rb'

set :server, "thin"
set :robot, Config::ROBOT

class Message
  attr_reader :content, :type
  PARSED_CONTENT = 1

  def initialize(message)
    @content = JSON.parse(message)
    @type = PARSED_CONTENT
  rescue => ex
    @content = message
    @type = nil
  end

  def parse
    if self.type
      content.inject("") {|words, pair| words += "> **#{pair[0]}**: #{pair[1]} \n\n"}
    else
      "> #{content}"
    end
  end
end

before do
  @request_body = JSON.parse request.body.read
  logger.info "Receive request body : #{@request_body}"
end

before do
  if request.env['HTTP_X_AMZ_SNS_MESSAGE_TYPE'] == 'SubscriptionConfirmation'
    RestClient.get @request_body["SubscribeURL"]
  end
end

before do
  if request.env['HTTP_X_AMZ_SNS_MESSAGE_TYPE'] == 'Notification'
    @subject = @request_body["Subject"]
    @message = Message.new(@request_body["Message"])
    @time = @request_body["Timestamp"]
  end
end

post '/test', :agent => /^Paw/ do
  json test: Message.parse(request.env)
end

post '/aws', :agent => /^Amazon/ do
  robot_message = {
     "msgtype": "markdown",
     "markdown": {
         "title": @subject || "AWS Send You An Alarm",
         "text": "### #{@subject}\n" +
                 "#{@message.parse}" +
                 "> ###### 时间 #{@time}"
     },
    "at": {
        "atMobiles": [
            Config::LIUSINING
        ],
        "isAtAll": false
    }
  }
  response = RestClient.post settings.robot, robot_message.to_json, {content_type: :json, accept: :json}
  logger.info "Sent to dingtalk: #{@subject}. Get status: #{response.code} and body: #{response.body}"
  status = 200
end
