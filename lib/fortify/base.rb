module Fortify
  class Base
    class_attribute :fortify_scope
    class_attribute :permission_context

    attr_reader :user, :record
    attr_accessor :access_list

    class << self
      def model_class(klass=nil)
        @model_class ||= (klass || self.name.chomp('Policy'))
      end

      def model
        @model = model_class.constantize
      end

      def fortify(&block)
        self.fortify_scope = Proc.new { none }
        self.permission_context = block_given? ? block : Proc.new { |user, record=nil| }
      end

      def scope(&block)
        self.fortify_scope = block
      end
    end

    def model
      self.class.model
    end

    def scope(&block)
      self.class.scope(&block)
    end

    def can(action, *fields)
      self.access_list[action] = [] unless access_list[action].present?

      if fields.present?
       access_list[action].concat(fields)
      else
       self.access_list[action] = model.attribute_names
      end
    end

    def cannot(action, *fields)
      return unless access_list[action].present?

      if fields.present?
        access_list[action].delete(fields)
      else
        access_list.delete(action)
      end

      access_list.delete(action) if access_list[action].empty?
    end

    def initialize(record)
      @user = Fortify.user
      @record = record
      self.access_list = HashWithIndifferentAccess.new
      permission_contexts = []
      
      self.class.ancestors.each do |klass|
        break if klass.permission_context.nil?
        permission_contexts.push klass.permission_context
      end
      
      while permission_contexts.any?
        self.instance_exec(user, record, &permission_contexts.pop)
      end
    end

    def method_missing(method, *args)
      action = method.to_s.gsub!(/^permitted_attributes_for_/, '')
      super unless action.present?

      access_list[action] || []
    end

    def can?(action, field=nil)
      if field.present?
        self.send("permitted_attributes_for_#{action}").map(&:to_s).include?(field.to_s)
      else
        access_list.keys.include?(action.to_s)
      end
    end
  end
end
