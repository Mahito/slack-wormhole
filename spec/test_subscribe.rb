# frozen_string_literal: true

require 'minitest/autorun'
require './lib/subscribe'

class SubscribeTest < Minitest::Test
  def setup
    @subscriber = SlackWormhole::Subscriber.new('test')
    @allow_channels = ENV['WORMHOLE_ALLOW_CHANNELS']
  end

  def teardown
    ENV['WORMHOLE_ALLOW_CHANNELS'] = @allow_channels
  end

  def test_subscriber_has_post_method
    assert_respond_to @subscriber, :post
  end

  def test_subscriber_has_update_method
    assert_respond_to @subscriber, :update
  end

  def test_subscriber_has_delete_method
    assert_respond_to @subscriber, :delete
  end

  def test_subscriber_has_reaction_add_method
    assert_respond_to @subscriber, :reaction_add
  end

  def test_subscriber_has_reaction_remove_method
    assert_respond_to @subscriber, :reaction_remove
  end

  def test_subscriber_has_post_reply_method
    assert_respond_to @subscriber, :post_reply
  end

  def test_allowed_channel_return_true_or_false
    ENV['WORMHOLE_ALLOW_CHANNELS'] = 'test, hoge'
    assert @subscriber.allowed_channel?('test')
    assert !@subscriber.allowed_channel?('test2')
  end

  def test_allowed_channel_return_true_when_allow_channels_is_nil
    ENV['WORMHOLE_ALLOW_CHANNELS'] = nil
    assert @subscriber.allowed_channel?('test')
  end
end
