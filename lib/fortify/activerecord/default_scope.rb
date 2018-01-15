module Fortify
  module ActiveRecord
    module DefaultScope
      extend ActiveSupport::Concern

      included do
        def self.default_scope
          self.fortified
        end
      end
      
    end
  end
end