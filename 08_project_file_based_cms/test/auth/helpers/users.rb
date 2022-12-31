# frozen_string_literal: true

require 'yaml'
require './auth/password_digester'

# :nocov:
module Test
  module Auth
    module Helpers
      # Manage test/dev users, including storage.
      class Users
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
            data[:password] = ::Auth::PasswordDigester.new_hash(data[:password])
            data
          end

          def encrypt_user_passwords(users)
            users.transform_values(&method(:encrypt_user_data))
          end
        end
      end
    end
  end
end
# :nocov:
