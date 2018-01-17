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

  describe "#authorize" do
    around(:each) do |example|
      Fortify.user = user
      example.run
      Fortify.user = nil
    end

    context "when authorized" do
      it "returns true" do
        expect {
          controller.authorize(user, :update)
        }.not_to raise_error(Fortify::NotAuthorizedError)
      end
    end

    context "when not authorized" do
      it "raises NotAuthorizedError" do
        expect {
          controller.authorize(user, :destroy)
        }.to raise_error(Fortify::NotAuthorizedError)
      end
    end
  end
end
