module Fortify
  module ActiveRecord
    module Base
      extend ActiveSupport::Concern

      class_methods do
        def fortified
          return all unless Fortify.enabled?

          raise InvalidUser.new("Fortify user not set") unless Fortify.user

          policy_scope
        end

        def policy_scope
          return unless policy_class
          self.instance_eval(&policy_class.new(self).fortify_scope)
        end

        def policy_class
          "#{self.name}Policy".constantize
        rescue NameError
          nil
        end
      end

      def can?(action, field=nil)
        policy.can?(action, field)
      end

      def policy
        @policy ||= self.class.policy_class.new(self) if self.class.policy_class
      end
    end
  end
end
