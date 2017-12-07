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
        if field.present?
          policy.send("permitted_attributes_for_#{action}").map(&:to_s).include?(field.to_s)
        else
          policy.access_map.keys.include?(action.to_s)
        end
      end

      def policy
        @policy ||= Fortify.policy(self)
      end
    end
  end
end
