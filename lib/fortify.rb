require 'pundit'
require 'active_record'
require 'active_support/core_ext'
require 'active_support/concern'

require "fortify/version"
require 'fortify/base'
require 'fortify/activerecord/base'
require 'fortify/activerecord/relation'
require 'fortify/activerecord/validation'
require 'fortify/activerecord/scoping'

module Fortify
  thread_mattr_accessor :user, instance_accessor: false
  thread_mattr_accessor :disabled, instance_accessor: false

  class Error < StandardError; end
  class NotDefinedError < Error; end

  class << self
    def activate!
      ::ActiveRecord::Base.send :include, Fortify::ActiveRecord::Scoping
      ::ActiveRecord::Base.send :include, Fortify::ActiveRecord::Base
      ::ActiveRecord::Relation.send :include, Fortify::ActiveRecord::Relation
      ::ActiveRecord::Base.send :include, Fortify::ActiveRecord::Validation
    end

    def policy_scope(scope)
      Pundit.policy_scope(user, scope)
    end

    def policy(record)
      Pundit.policy(user, record)
    end

    def disabled?
      disabled == true
    end

    def insecurely
      self.disabled = true
      yield
    ensure
      self.disabled = false
    end
  end
end
