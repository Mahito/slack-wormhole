require 'minitest/autorun'
require 'hashie'
require './lib/utils'

class UtilsTest < Minitest::Test
  def setup
    @user_stub = Hashie::Mash.new
    @user_stub.profile = Hashie::Mash.new
  end

  def test_username_at_display_name()
    @user_stub.profile.display_name = 'display_name'
    Object.stub(:user, @user_stub) do
      assert 'display_name', username(@user_stub)
    end
  end

  def test_username_at_real_name()
    @user_stub.profile.display_name = ''
    @user_stub.real_name = 'real_name'
    Object.stub(:user, @user_stub) do
      assert 'real_name', username(@user_stub)
    end
  end

  def test_username_at_name()
    @user_stub.profile.display_name = ''
    @user_stub.real_name = ''
    @user_stub.name = 'name'
    Object.stub(:user, @user_stub) do
      assert 'name', username(@user_stub)
    end
  end

  def test_username_is_blank()
    @user_stub.profile.display_name = ''
    @user_stub.real_name = ''
    @user_stub.name = ''
    Object.stub(:user, @user_stub) do
      assert '', username(@user_stub)
    end
  end
end
