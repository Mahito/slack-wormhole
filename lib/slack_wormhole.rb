# frozen_string_literal: true

require_relative  'publish'
require_relative  'subscribe'

subscribers = []
subscription_names = ENV['WORMHOLE_SUBSCRIPTION_NAMES']

SlackWormhole::Publish.start

subscription_names.split(',').each do |name|
  subscribers << SlackWormhole::Subscriber.start(name)
end
