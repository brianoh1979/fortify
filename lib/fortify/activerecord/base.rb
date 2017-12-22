module Fortify
  module ActiveRecord
    module Base
      extend ActiveSupport::Concern

      included do
        def self.default_scope
          return all unless Fortify.enabled?
          raise InvalidUser.new("Fortify user not set") unless Fortify.user

          Fortify.policy_scope(self)
        end
      end

      def can?(action, field=nil)
        policy.can?(action, field)
      end

      def policy
        @policy ||= Fortify.policy(self)
      end
    end
  end
end
