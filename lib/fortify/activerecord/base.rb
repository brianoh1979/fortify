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

      def policy
        Fortify.policy(self)
      end
    end
  end
end
