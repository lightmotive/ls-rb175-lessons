# frozen_string_literal: true

require_relative 'auth_test_helper'
TemporaryTestUsers.create
# Rakefile invokes `TemporaryTestUsers.destroy` after :test task

require_relative 'test_helper'
require './models/authenticator'

class URLUtilsTest < MiniTest::Test
  def test_production_environment_not_valid
    rack_env = ENV.fetch('RACK_ENV', nil)
    ENV['RACK_ENV'] = 'production'
    user = TemporaryTestUsers['admin']
    auth = Models::Authenticator.new({ username: 'admin', password: user[:password] })
    assert_equal false, auth.valid?
    ENV['RACK_ENV'] = rack_env
  end

  def test_empty_password_unauthorized
    auth = Models::Authenticator.new({ username: 'admin', password: '' })
    assert_equal false, auth.valid?
  end

  def test_user_not_found_unauthorized
    auth = Models::Authenticator.new({ username: 'nobody!', password: '' })
    assert_equal false, auth.valid?
  end

  def test_file_based_test_users
    user = TemporaryTestUsers['admin']
    auth = Models::Authenticator.new({ username: 'admin', password: user[:password] })
    assert_equal true, auth.valid?
  end
end
