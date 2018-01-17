module Fortify
  module ActiveRecord
    module Base
      extend ActiveSupport::Concern

      class_methods do
        def fortified
          return all unless Fortify.enabled?

          raise InvalidUserError.new("Fortify user not set") unless Fortify.user

          policy_scope
        end

        def policy_scope
          self.instance_eval(&policy_class.new(self).fortify_scope)
        end

        def policy_class
          "#{self.name}Policy".constantize
        rescue NameError
          raise Fortify::MissingPolicyError.new("Missing policy for model #{self.name}")
        end

        def policy
          policy_class.new(self)
        end

        def can?(action, field=nil)
          policy.can?(action, field)
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
