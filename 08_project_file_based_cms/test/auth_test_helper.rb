# frozen_string_literal: true

require 'yaml'
require 'random/formatter'
require 'securerandom'
require './cms_app_helper'
require './auth/password_digester'

class TestUsers
  TEST_DATA_PATH = './test/users.yml'

  class << self
    def all
      YAML.load_file(TEST_DATA_PATH)
    end

    def [](username)
      all.fetch(username, nil)
    end

    def save(users)
      File.write(TEST_DATA_PATH, users.empty? ? '' : users.to_yaml)
    end

    def secure_and_save(users)
      secure_users = encrypt_user_passwords(users)
      save(secure_users)
    end

    def create(username, type, password)
      users = all
      users[username] = { type:, password: }
      save(users)
    end

    def change_password(username, password)
      users = all
      users[username] = encrypt_user_data({ type:, password: })
      save(users)
    end

    def delete(username)
      users = all
      users.delete(username)
      save(users)
    end

    private

    def encrypt_user_data(data)
      data = data.dup
      data[:password] = Auth::PasswordDigester.new_hash(data[:password])
      data
    end

    def encrypt_user_passwords(users)
      users.transform_values(&method(:encrypt_user_data))
    end
  end
end

# Generate temporary test users for local development and testing without
# saving user data in the codebase.
class TemporaryTestUsers
  class << self
    def create
      @unencrypted_data = {
        'admin' => { type: :admin, password: SecureRandom.alphanumeric(18) },
        'user1' => { type: :user, password: SecureRandom.alphanumeric(18) }
      }
      TestUsers.secure_and_save(@unencrypted_data)
      return unless development?

      # :nocov:
      puts '** Temporary user data created ("username" => { user data }) **'
      puts 'Use one of the following temporary credentials during this dev session:'
      pp TemporaryTestUsers.all_unencrypted
      puts
      # :nocov:

      nil
    end

    def all_unencrypted
      @unencrypted_data
    end

    def [](username)
      @unencrypted_data[username]
    end

    def destroy
      TestUsers.save({})
      puts "\nTemporary credential file cleared." if development?
    end
  end
end

# :nocov:
return unless __FILE__ == $PROGRAM_NAME && !ARGV.empty?

action = ARGV[0]
case action
when 'create-temp-users'
  TemporaryTestUsers.create
when 'destroy-temp-users'
  TemporaryTestUsers.destroy
when 'create-user'
  TestUsers.create(*ARGV[1..])
when 'delete-user'
  TestUsers.delete(ARGV[1])
when 'change-user-password'
  TestUsers.change_password(ARGV[1..])
end
# :nocov:
