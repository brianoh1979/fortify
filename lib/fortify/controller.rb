module Fortify
  module Controller
    extend ActiveSupport::Concern

    included do
      around_action :run_securely
    end

    def fortify_user
      current_user
    end

    def set_fortify_user
      Fortify.user = fortify_user
      yield
    ensure
      # to address the thread variable leak issues in Puma/Thin webserver
      Fortify.user = nil
    end

    def authorize(record)
      raise NotAuthorizedError unless record.policy.public_send(params[:action] + "?")
    end
    
    def run_securely
      prior_enabled_state = Fortify.enabled
      Fortify.enabled = true
      Fortify.user = fortify_user
      yield
    ensure
      # to address the thread variable leak issues in Puma/Thin webserver
      Fortify.user = nil
      Fortify.enabled = prior_enabled_state
    end
  end
end
