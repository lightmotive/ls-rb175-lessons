# frozen_string_literal: true

require_relative 'temp_users'

# :nocov:
return unless __FILE__ == $PROGRAM_NAME && !ARGV.empty?

action = ARGV[0]
case action
when 'create-temp-users'
  Auth::TestHelpers::TempUsers.create
when 'destroy-temp-users'
  Auth::TestHelpers::TempUsers.destroy
when 'create-user'
  Auth::TestHelpers::Users.create(*ARGV[1..])
when 'delete-user'
  Auth::TestHelpers::Users.delete(ARGV[1])
when 'change-user-password'
  Auth::TestHelpers::Users.change_password(ARGV[1..])
end
# :nocov:
