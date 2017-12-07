module Fortify
  module ActiveRecord
    module Validation
      extend ActiveSupport::Concern

      MESSAGE = "You are not authorizated to perform this action".freeze

      included do
        before_validation :check_if_creatable, on: :create
        before_validation :check_if_updatable, on: :update
        before_validation :check_attribute_for_create, on: :create
        before_validation :check_attribute_for_update, on: :update
        before_destroy :check_if_destroyable
      end

      private

      def check_if_creatable
        return unless Fortify.enabled?

        unless policy.create?
          errors.add(:base, MESSAGE)
        end
      end

      def check_if_updatable
        return unless Fortify.enabled?

        unless policy.update?
          errors.add(:base, MESSAGE)
        end
      end

      def check_if_destroyable
        return unless Fortify.enabled?

        unless policy.destroy?
          errors.add(:base, MESSAGE)
          throw(:abort)
        end
      end

      def check_attribute_for_create
        return unless Fortify.enabled?

        attrs = changed_attributes.keys - policy.permitted_attributes_for_create.map(&:to_s)

        attrs.each do |attr|
          errors.add(attr, MESSAGE)
        end
      end

      def check_attribute_for_update
        return unless Fortify.enabled?

        attrs = changed_attributes.keys - policy.permitted_attributes_for_update.map(&:to_s)

        attrs.each do |attr|
          errors.add(attr, MESSAGE)
        end
      end
    end
  end
end
