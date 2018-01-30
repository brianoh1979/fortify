module Fortify
  module ActiveRecord
    module Base
      extend ActiveSupport::Concern

      class_methods do
        def fortified
          return all unless Fortify.enabled?

          policy_scope
        end

        def policy_scope
          self.instance_eval(&policy.fortify_scope)
        end

        def policy
          Fortify.policy(self)
        end

        def can?(action, field=nil)
          policy.can?(action, field)
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
