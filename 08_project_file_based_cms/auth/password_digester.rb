# frozen_string_literal: true

require 'bcrypt'

module Auth
  class PasswordDigester
    class << self
      def new_hash(new_password)
        hash = BCrypt::Password.create(new_password)
        BCrypt::Password.new(hash).to_str
      end

      def match?(hash, password)
        return false if hash.nil? || password.nil?

        BCrypt::Password.new(hash) == password
      end
    end
  end
end
