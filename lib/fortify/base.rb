module Fortify
  class Base
    class_attribute :permission_proc
    # TODO: Upgrade Rails to 5.1 to set default on class_attribute
    self.permission_proc = Proc.new { |user| }

    thread_mattr_accessor :access_map, instance_writer: false
    thread_mattr_accessor :scope_proc, instance_writer: false

    attr_reader :user, :record

    class << self
      def model_class(klass=nil)
        @model_class ||= (klass || self.name.chomp('Policy').constantize)
      end

      def fortify(&block)
        self.permission_proc = block
      end

      def setup_permission(user)
        # Setting defaults
        self.access_map = HashWithIndifferentAccess.new
        self.scope_proc = Proc.new { none }

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

      def scope(&block)
        self.scope_proc = block
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

    def can?(action, field=nil)
      if field.present?
        self.send("permitted_attributes_for_#{action}").map(&:to_s).include?(field.to_s)
      else
        access_map.keys.include?(action.to_s)
      end
    end
  end
end
