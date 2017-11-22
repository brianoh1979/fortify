module Fortify
  module ActiveRecord
    module Base
      extend ::ActiveSupport::Concern

      included do
        class_attribute :fortified

        def self.safe
          Fortify.policy_scope(self)
        end
      end

      def can?(action, field=nil)
        return false unless policy.respond_to?("#{action}?") && policy.public_send("#{action}?")
        return true unless field.present?

        method_name = if policy.respond_to?("permitted_attributes_for_#{action}")
            "permitted_attributes_for_#{action}"
          else
            "permitted_attributes"
          end

        permitted_attributes = policy.public_send(method_name).map(&:to_s)

        return permitted_attributes.include?(field.to_s)
      end

      def policy
        @policy ||= Fortify.policy(self)
      end
    end
  end
end
