module Fortify
  class Base
    class_attribute :scopes
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
        self.scopes = nil
        self.permission_context = block_given? ? block : Proc.new { |user, record=nil| }
      end

      def scope(&block)
        if self.scopes
          self.scopes = proc { block.call(self.scopes.call) } #FIXME - this doesn't work because self changes
        else
          self.scopes = block
        end
      end

      def fortify_scope
        if self.scopes
          scopes
        else 
          proc { none }
        end
      end
    end

    def model
      self.class.model
    end

    def scope(&block)
      self.class.scope(&block)
    end

    def fortify_scope
      self.class.fortify_scope
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
