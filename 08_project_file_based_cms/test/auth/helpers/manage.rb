# frozen_string_literal: true

require_relative 'temp_users'

# :nocov:
return unless __FILE__ == $PROGRAM_NAME && !ARGV.empty?

action = ARGV[0]
case action
when 'create-temp-users'
  Test::Auth::Helpers::TempUsers.create
when 'destroy-temp-users'
  Test::Auth::Helpers::TempUsers.destroy
when 'create-user'
  Test::Auth::Helpers::Users.create(*ARGV[1..])
when 'delete-user'
  Test::Auth::Helpers::Users.delete(ARGV[1])
when 'change-user-password'
  Test::Auth::Helpers::Users.change_password(ARGV[1..])
end
# :nocov:
