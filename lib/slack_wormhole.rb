# frozen_string_literal: true

require_relative  'publish'
require_relative  'subscribe'

subscribers = []
subscription_names = ENV['WORMHOLE_SUBSCRIPTION_NAMES']

subscription_names.split(',').each do |name|
  subscribers << SlackWormhole::Subscriber.start(name)
end

begin
  SlackWormhole::Publish.start
rescue StandardError
  retry
end
