require "spec_helper"

RSpec.describe Fortify::Controller do
  let(:user) { Fortify.insecurely { User.find_by(name: "default-user") } }
  let(:controller) { MyController.new(user) }

  describe "#fortify_user" do
    it "is set to current_user" do
      expect(controller.fortify_user).to eq(user)
    end
  end

  describe "#run_securely" do
    it "sets Fortify.user and then resets it" do
      expect(Fortify.user).to eq(nil)

      controller.run_securely do
        expect(Fortify.user).to eq(user)
      end

      expect(Fortify.user).to eq(nil)
    end

    it "sets Fortify.enabled and then resets it" do
      expect(Fortify.enabled).to eq(nil)

      controller.run_securely do
        expect(Fortify.enabled).to eq(true)
      end

      expect(Fortify.enabled).to eq(nil)
    end

    it "sets nesting variable" do
      expect(controller.instance_variable_get(:@securely_nesting)).to eq(nil)

      controller.run_securely do
        expect(controller.instance_variable_get(:@securely_nesting)).to eq(1)

        controller.run_securely do
          expect(controller.instance_variable_get(:@securely_nesting)).to eq(2)
        end

        expect(controller.instance_variable_get(:@securely_nesting)).to eq(1)
      end
      
      expect(controller.instance_variable_get(:@securely_nesting)).to eq(0)
    end
  end
end
