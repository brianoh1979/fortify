class MyController
  class << self
    def around_action(method); end
  end

  include Fortify::Controller

  attr_reader :current_user

  def initialize(current_user)
    @current_user = current_user
  end
end
