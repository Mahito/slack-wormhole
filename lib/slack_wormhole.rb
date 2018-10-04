require 'slack-ruby-client'

Slack.configure do |config|
  config.token = ENV['SLACK_API_TOKEN']
  raise 'Missing ENV[SLACK_API_TOKEN]!' unless config.token

  config.logger = Logger.new(STDOUT)
  config.logger.level = Logger::INFO
end

client = Slack::RealTime::Client.new

client.on :message do |data|

end

client.start!
