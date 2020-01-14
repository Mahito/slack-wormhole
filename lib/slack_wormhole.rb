# frozen_string_literal: true

require_relative  'publish'
require_relative  'subscribe'

SlackWormhole::Subscriber.start
SlackWormhole::Publish.start
