require 'google/cloud/pubsub'
require 'slack-ruby-client'

Slack.configure do |config|
  config.token = ENV['SLACK_API_TOKEN']
  raise 'Missing ENV[SLACK_API_TOKEN]!' unless config.token

  config.logger = Logger.new(STDOUT)
  config.logger.level = Logger::INFO
end

def pubsub
  if @pubsub
    @pubsub
  else
    @pubsub = Google::Cloud::Pubsub.new(
      project_id: ENV['GCP_PROJECT'],
      credentials: ENV['GOOGLE_APPLICATION_CREDENTIALS']
    )
  end
end

def topic
  if @topic
    return @topic
  else
    topic_name = ENV['WORMHOLE_TOPIC_NAME']
    @topic = pubsub.topic(topic_name)
  end
end

def rtm
  if @rtm
    @rtm
  else
    @rtm = Slack::RealTime::Client.new
  end
end

def web
  if @web
    @web
  else
    @web = Slack::Web::Client.new
  end
end

def channel(id)
  web.channels_info(channel: id).channel
end

def user(id)
  web.users_info(user: id).user if id
end
