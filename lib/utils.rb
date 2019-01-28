require "google/cloud/datastore"
require 'google/cloud/pubsub'
require 'slack-ruby-client'

Slack::Web::Client.configure do |config|
  config.token = ENV['SLACK_API_USER_TOKEN']
  raise 'Missing ENV[SLACK_API_USER_TOKEN]!' unless config.token

  STDOUT.sync = true

  config.logger = Logger.new(STDOUT)
  config.logger.level = Logger::INFO
end

Slack::RealTime::Client.configure do |config|
  config.token = ENV['SLACK_API_BOT_TOKEN']
  raise 'Missing ENV[SLACK_API_BOT_TOKEN]!' unless config.token

  STDOUT.sync = true

  config.logger = Logger.new(STDOUT)
  config.logger.level = Logger::INFO
end

def logger
  if @logger
    @logger
  else
    @logger = Logger.new(STDOUT)
  end
end

def datastore
  if @datastore
    @datastore
  else
    @datastore = Google::Cloud::Datastore.new(
      project_id: ENV['GCP_PROJECT_ID'],
      credentials: ENV['GOOGLE_APPLICATION_CREDENTIALS']
    )
  end
end

def pubsub
  if @pubsub
    @pubsub
  else
    @pubsub = Google::Cloud::Pubsub.new(
      project_id: ENV['GCP_PROJECT_ID'],
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

def query
  query = datastore.query(ENV['WORMHOLE_ENTITY_NAME'])
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

def username(user)
  username = user.profile.display_name
  username = user.real_name if username == ""
  username = user.name if username == ""
  return username
end
