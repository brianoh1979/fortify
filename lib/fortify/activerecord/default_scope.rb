module Fortify
  module ActiveRecord
    module DefaultScope
      extend ActiveSupport::Concern

      included do
        default_scope { fortified }
      end
    end
  end
end
