module Fortify
  module ActiveRecord
    module Scoping
      extend ActiveSupport::Concern

      def populate_with_current_scope_attributes # :nodoc:
        return
      end
    end
  end
end
