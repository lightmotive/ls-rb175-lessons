# frozen_string_literal: true

require './test/auth/helpers'
Test::Auth::Helpers::TempUsers.create
# Rakefile invokes `Test::Auth::Helpers::TempUsers.destroy` after :test task

require_relative 'test_helper'
require './models/authenticator'

class MockValidateUnAndPw
  UN_VALID = 'mock'
  PW_VALID = 'abc123'

  class << self
    def accept_credentials?(credentials)
      credentials.fetch(:username, false) &&
        credentials.fetch(:password, false)
    end
  end

  def initialize(credentials)
    @credentials = credentials
  end

  def valid?
    credentials[:username] == UN_VALID && credentials[:password] == PW_VALID
  end

  private

  attr_reader :credentials
end

class AuthenticatorTest < MiniTest::Test
  def test_mock_validator_with_valid_credentials
    auth = Models::Authenticator.new(
      { username: MockValidateUnAndPw::UN_VALID,
        password: MockValidateUnAndPw::PW_VALID },
      validation_systems: [MockValidateUnAndPw]
    )
    assert_equal true, auth.valid?
  end

  def test_mock_validator_with_invalid_credentials
    auth = Models::Authenticator.new(
      { username: 'anybody',
        password: '123abc' },
      validation_systems: [MockValidateUnAndPw]
    )
    assert_equal false, auth.valid?
  end

  def test_not_valid_when_no_validation_systems
    auth = Models::Authenticator.new({}, validation_systems: [])
    assert_equal false, auth.valid?
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
    user = Test::Auth::Helpers::TempUsers['admin']
    auth = Models::Authenticator.new({ username: 'admin', password: user[:password] })
    assert_equal true, auth.valid?
  end
end
