require "spec_helper"

RSpec.describe Fortify::Controller do
  let(:user) { Fortify.insecurely { User.find_by(name: "default-user") } }
  let(:controller) { MyController.new(user) }

  describe "#fortify_user" do
    it "is set to current_user" do
      expect(controller.fortify_user).to eq(user)
    end
  end

  describe "#set_fortify_user" do
    it "sets Fortify.user" do
      expect(Fortify.user).to eq(nil)

      controller.set_fortify_user do
        expect(Fortify.user).to eq(user)
      end

      expect(Fortify.user).to eq(nil)
    end
  end
end
