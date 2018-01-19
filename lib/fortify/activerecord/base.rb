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
          fortify_scopes = policy_class.new(self).fortify_scopes
          fortify_scopes.inject(self) { |subject, scope| subject.instance_eval(&scope) }
        end

        def policy_class
          "#{self.name}Policy".constantize
        rescue NameError
          raise Fortify::MissingPolicyError.new("Missing policy for model #{self.name}")
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


