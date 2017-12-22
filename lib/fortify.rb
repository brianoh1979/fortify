require 'pundit'
require 'active_record'
require 'active_support/core_ext'
require 'active_support/concern'

require "fortify/version"
require 'fortify/base'
require 'fortify/activerecord/base'
require 'fortify/activerecord/validation'
require 'fortify/activerecord/scoping'

module Fortify
  thread_mattr_accessor :user, instance_accessor: false
  thread_mattr_accessor :enabled, instance_accessor: false

  class Error < StandardError; end
  class NotDefinedError < Error; end
  class InvalidUser < Error; end

  class << self
    def set_user(user)
      self.user = user
      policies.each { |policy| policy.setup_permission(user) }
    end

    def policies
      @policies ||= ObjectSpace.each_object(Class).select { |klass| klass < Fortify::Base }
    end

    def policy_scope(klass)
      klass.instance_eval(&policy(klass).scope_proc) if policy(klass)
    end

    def policy(record)
      # TODO: raise a detailed exception when there is no user set
      Pundit.policy(user, record)
    end

    def enabled?
      self.enabled != false
    end

    def insecurely
      self.enabled = false
      yield
    ensure
      self.enabled = true
    end
  end
end

ActiveSupport.on_load(:active_record) do
  def self.set_fortify(options={})
    include Fortify::ActiveRecord::Base
    include Fortify::ActiveRecord::Validation
    include Fortify::ActiveRecord::Scoping
  end
end
