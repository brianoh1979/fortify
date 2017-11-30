module Fortify
  class Base
    attr_reader :user, :record

    def permitted_attributes
      []
    end

    def permitted_attributes_for_update
      []
    end

    def permitted_attributes_for_create
      []
    end

    def initialize(user, record)
      @user = user
      @record = record
    end

    def scope
      Fortify.policy_scope(record.class)
    end

    class Scope
      attr_reader :user, :scope

      def initialize(user, scope)
        @user = user
        @scope = scope
      end

      def resolve
        scope
      end
    end

    def self.scope(&block)
      #Define Scope subclass on policy class with Fortify::Base::Scope as parent class and override resolve method
      self.const_set("Scope", Class.new(Scope)).send(:define_method, :resolve, &block)
    end
  end
end
