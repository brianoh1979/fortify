module Fortify
  module Controller
    extend ActiveSupport::Concern

    included do
      around_action :set_fortify_user
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
  end
end
