# frozen_string_literal: true

require 'yaml'

# TODO: set the following env vars using environment management systems:
# - For dev and test: https://github.com/bkeepers/dotenv
# - For production, use host framework's secure environment management system.
ENV['RACK_ENV'] = 'test'

class TestUsers
  TEST_USERS_PATH = './test/users.yml'

  class << self
    def all
      YAML.load_file(TEST_USERS_PATH)
    end

    def [](username)
      users = all
      users.fetch(username, nil)
    end

    def save(users)
      File.write(TEST_USERS_PATH, users.to_yaml)
    end

    def create(username, type, password)
      users = all
      users[username] = { type:, password: }
      save(users)
    end

    def change_password(username, password); end

    def delete(username)
      users = all
      users.delete(username)
      save(users)
    end
  end
end

# :nocov:
return unless __FILE__ == $PROGRAM_NAME && !ARGV.empty?

action = ARGV[0]
case action
when 'create'
  TestUsers.create(*ARGV[1..])
when 'delete'
  TestUsers.delete(ARGV[1])
when 'change-pw'
  TestUsers.change_password(ARGV[1..])
end
# :nocov:
