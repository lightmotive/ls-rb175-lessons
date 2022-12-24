# frozen_string_literal: true

# TODO: set the following env vars using environment management systems:
# - For dev and test: https://github.com/bkeepers/dotenv
# - For production, use host framework's secure environment management system.
ENV['RACK_ENV'] = 'test'

def test_user(username)
  test_users = YAML.load_file('./auth/test_users.yaml')
  test_users.fetch(username, nil)
end
