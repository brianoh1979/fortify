module Fortify
  class Base
    class_attribute :permission_proc
    thread_mattr_accessor :access_map
    thread_mattr_accessor(:default_scope_proc) { none }

    attr_reader :user, :record

    class << self
      def model_class
        @model_class ||= self.name.chomp('Policy').constantize
      end

      def fortify(&block)
        self.permission_proc = block
      end

      def setup_permission(user)
        self.access_map = HashWithIndifferentAccess.new
        self.permission_proc.call(user)
      end

      def can(action, *fields)
        access_map[action] = [] unless access_map[action].present?

        if fields.present?
          access_map[action].concat(fields)
        else
          access_map[action] = model_class.attribute_names
        end
      end

      def cannot(action, *fields)
        return unless access_map[action].present?

        if fields.present?
          access_map[action].delete(fields)
        else
          access_map.delete(action)
        end

        access_map.delete(action) if access_map[action].empty?
      end

      def default_scope(&block)
        self.default_scope_proc = block
      end
    end

    def initialize(user, record)
      @user = user
      @record = record
    end

    def method_missing(method, *args)
      action = method.to_s.gsub!(/^permitted_attributes_for_/, '')
      super unless action.present?

      access_map[action] || []
    end
  end
end
