require_relative  'publish'
require_relative  'subscribe'

SlackWormhole::Subscribe.start
SlackWormhole::Publish.start
