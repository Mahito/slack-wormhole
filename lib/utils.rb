# frozen_string_literal: true

require 'google/cloud/datastore'
require 'google/cloud/pubsub'
require 'slack-ruby-client'
require 'base64'
require 'json'

Slack::Web::Client.configure do |config|
  config.token = ENV['SLACK_API_USER_TOKEN']
  raise 'Missing ENV[SLACK_API_USER_TOKEN]!' unless config.token

  $stdout.sync = true

  config.logger = Logger.new($stdout)
  config.logger.level = Logger::INFO
end

Slack::RealTime::Client.configure do |config|
  config.token = ENV['SLACK_API_BOT_TOKEN']
  raise 'Missing ENV[SLACK_API_BOT_TOKEN]!' unless config.token

  $stdout.sync = true

  config.logger = Logger.new($stdout)
  config.logger.level = Logger::INFO
end

def logger
  @logger ||= Logger.new($stdout)
end

def datastore
  if @datastore
    @datastore
  elsif ENV['GOOGLE_APPLICATION_CREDENTIALS']
    @datastore = Google::Cloud::Datastore.new(
      project_id: ENV['GCP_PROJECT_ID'],
      credentials: ENV['GOOGLE_APPLICATION_CREDENTIALS']
    )
  else
    @datastore = Google::Cloud::Datastore.new(project_id: ENV['GCP_PROJECT_ID'])
  end
end

def pubsub
  if @pubsub
    @pubsub
  elsif ENV['GOOGLE_APPLICATION_CREDENTIALS']
    @pubsub = Google::Cloud::Pubsub.new(
      project_id: ENV['GCP_PROJECT_ID'],
      credentials: ENV['GOOGLE_APPLICATION_CREDENTIALS']
    )
  else
    @pubsub = Google::Cloud::Pubsub.new(project_id: ENV['GCP_PROJECT_ID'])
  end
end

def topic
  @topic ||= pubsub.topic(ENV['WORMHOLE_TOPIC_NAME'])
end

def query
  datastore.query(ENV['WORMHOLE_ENTITY_NAME'])
end

def rtm
  @rtm ||= Slack::RealTime::Client.new
end

def web
  @web ||= Slack::Web::Client.new
end

def channel(id)
  web.conversations_info(channel: id).channel
end

def user(id)
  web.users_info(user: id).user if id
end

def username(user)
  username = user.profile.display_name
  username = user.real_name if username.empty?
  username = user.name if username.empty?
  username
end
