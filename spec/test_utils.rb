# frozen_string_literal: true

require 'minitest/autorun'
require 'hashie'
require './lib/utils'

class UtilsTest < Minitest::Test
  def setup
    @user_stub = Hashie::Mash.new
    @user_stub.profile = Hashie::Mash.new
  end

  def test_logger_return_object
    assert_kind_of Logger, logger
  end

  def test_logger_return_same_object
    target = logger
    assert_equal target.object_id, logger.object_id
  end

  def test_rtm_return_object
    assert_kind_of Slack::RealTime::Client, rtm
  end

  def test_rtm_return_same_object
    target = rtm
    assert_equal target.object_id, rtm.object_id
  end

  def test_web_return_object
    assert_kind_of Slack::Web::Client, web
  end

  def test_web_return_same_object
    target = web
    assert_equal target.object_id, web.object_id
  end

  def test_username_at_display_name
    @user_stub.profile.display_name = 'display_name'
    Object.stub(:user, @user_stub) do
      assert_equal 'display_name', username(@user_stub)
    end
  end

  def test_username_at_real_name
    @user_stub.profile.display_name = ''
    @user_stub.real_name = 'real_name'
    Object.stub(:user, @user_stub) do
      assert_equal 'real_name', username(@user_stub)
    end
  end

  def test_username_at_name
    @user_stub.profile.display_name = ''
    @user_stub.real_name = ''
    @user_stub.name = 'name'
    Object.stub(:user, @user_stub) do
      assert_equal 'name', username(@user_stub)
    end
  end

  def test_username_is_blank
    @user_stub.profile.display_name = ''
    @user_stub.real_name = ''
    @user_stub.name = ''
    Object.stub(:user, @user_stub) do
      assert_equal '', username(@user_stub)
    end
  end
end
