# frozen_string_literal: true

require './cms_app_helper'
require 'random/formatter'
require 'securerandom'
require_relative 'users'

module Test
  module Auth
    module Helpers
      # Generate temporary test users for local development and testing without
      # saving any credentials in the codebase.
      class TempUsers
        class << self
          def create
            @unencrypted_data = {
              'admin' => { type: :admin, password: SecureRandom.alphanumeric(18) },
              'user1' => { type: :user, password: SecureRandom.alphanumeric(18) }
            }
            Users.secure_and_save(@unencrypted_data)
            return unless development?

            # :nocov:
            puts '** Temporary credentials created ("username" => { user data }) **'
            puts 'Use one of the following during this dev session:'
            pp TempUsers.all_unencrypted
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
            Users.save({})
            puts "\nTemporary credentials cleared." if development?
          end
        end
      end
    end
  end
end
