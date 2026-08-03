# frozen_string_literal: true

require_relative 'test_helper'
require 'ostruct'
require_relative '../lib/utils'

class UtilsTest < Minitest::Test
  def setup
    @user_stub = OpenStruct.new(profile: OpenStruct.new)
  end

  def test_logger_return_object
    assert_kind_of Logger, logger
  end

  def test_logger_return_same_object
    target = logger
    assert_equal target.object_id, logger.object_id
  end

  def test_slack_api_token_uses_v2_env
    assert_equal 'test-token', Slack.config.token
  end

  def test_slack_api_token_falls_back_to_legacy_env
    original_v2_token = ENV.delete('SLACK_API_TOKEN')
    original_legacy_token = ENV['SLACK_API_USER_TOKEN']
    ENV['SLACK_API_USER_TOKEN'] = 'legacy-token'

    load File.expand_path('../lib/utils.rb', __dir__)

    assert_equal 'legacy-token', Slack.config.token
  ensure
    ENV['SLACK_API_TOKEN'] = original_v2_token
    ENV['SLACK_API_USER_TOKEN'] = original_legacy_token
    load File.expand_path('../lib/utils.rb', __dir__)
  end

  def test_slack_api_token_requires_v2_env
    original_v2_token = ENV.delete('SLACK_API_TOKEN')
    original_legacy_token = ENV.delete('SLACK_API_USER_TOKEN')

    error = assert_raises(RuntimeError) do
      load File.expand_path('../lib/utils.rb', __dir__)
    end

    assert_equal 'Missing ENV[SLACK_API_TOKEN]!', error.message
  ensure
    ENV['SLACK_API_TOKEN'] = original_v2_token
    ENV['SLACK_API_USER_TOKEN'] = original_legacy_token
    load File.expand_path('../lib/utils.rb', __dir__)
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
