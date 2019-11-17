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

  def test_allowed_channel_return_true_or_false
    ENV['WORMHOLE_ALLOW_CHANNELS'] = 'test, hoge'
    assert SlackWormhole::Subscribe.allowed_channel?('test')
    assert !SlackWormhole::Subscribe.allowed_channel?('test2')
  end

  def test_allowed_channel_return_true_when_allow_channels_is_nil
    ENV['WORMHOLE_ALLOW_CHANNELS'] = nil
    assert SlackWormhole::Subscribe.allowed_channel?('test')
  end
end
