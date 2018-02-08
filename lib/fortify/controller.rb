module Fortify
  module Controller
    extend ActiveSupport::Concern

    included do
      around_action :run_securely
    end

    def fortify_user
      current_user
    end

    def run_securely
      @securely_nesting ||= 0
      @securely_nesting += 1

      if @securely_nesting == 1
        prior_enabled_state = Fortify.enabled
        Fortify.enabled = true
        Fortify.user = fortify_user
      end

      yield
    ensure
      @securely_nesting -= 1

      if @securely_nesting == 0
        # to address the thread variable leak issues in Puma/Thin webserver
        Fortify.user = nil
        Fortify.enabled = prior_enabled_state
      end
    end
  end
end
