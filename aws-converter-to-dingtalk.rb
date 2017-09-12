require 'sinatra'
require 'json'
require 'sinatra/json'
require 'sinatra/reloader' if development?
require 'rest-client'
require_relative '.env'

set :robot, Config::ROBOT

before do
  request.body.rewind
  @request_body = JSON.parse request.body.read
end

before do
  if request.env['HTTP_X_AMZ_SNS_MESSAGE_TYPE'] == 'SubscriptionConfirmation'
    RestClient.get @request_body["SubscribeURL"]
  end
end

before do
  if request.env['HTTP_X_AMZ_SNS_MESSAGE_TYPE'] == 'Notification'
    @subject = @request_body["Subject"]
    @message = @request_body["Message"]
    @time = @request_body["Timestamp"]
  end
end

post '/aws/codedeploy-bluegreen' do
  robot_message = {
     "msgtype": "markdown",
     "markdown": {
         "title": @subject,
         "text": "### #{@subject}\n" +
                 "> #{@message}\n\n" +
                 "> ###### 时间 #{@time}"
     },
    "at": {
        "atMobiles": [
            Config::LIUSINING
        ],
        "isAtAll": false
    }
  }
  RestClient.post settings.robot, robot_message.to_json, {content_type: :json, accept: :json}
  status = 200
end
