# frozen_string_literal: true

require 'minitest/autorun'
require './lib/subscribe'

class UtilsTest < Minitest::Test
  def setup
    @allow_channels = ENV['WORMHOLE_ALLOW_CHANNELS']
  end

  def teardown
    ENV['WORMHOLE_ALLOW_CHANNELS'] = @allow_channelsS
  end

  def test_allowed_channel_return_true
    ENV['WORMHOLE_ALLOW_CHANNELS'] = 'test, hoge'
    assert SlackWormhole::Subscribe.allowed_channel?('test')
  end

  def test_allowed_channel_return_false
    ENV['WORMHOLE_ALLOW_CHANNELS'] = nil
    assert !SlackWormhole::Subscribe.allowed_channel?('test')
  end
end
