require "spec_helper"

RSpec.describe Fortify do
  it "has a version number" do
    expect(Fortify::VERSION).not_to be nil
  end

  describe "setup" do
    it "includes active_record" do
      expect(ActiveRecord::Base).to be
    end

    it "loads the fixtures" do
      expect(Project.count).to be 2
    end

    it "loads models and associations properly" do
      expect(User.find_by(name: "default-user").projects.first.name).to eq "Default Project"
      expect(User.find_by(name: "default-user").projects.first.tasks.first.name).to eq "Default Task"
    end

    it "loads policies properly" do
      [UserPolicy, TaskPolicy, ProjectPolicy].each do |policy|
        expect(policy.ancestors).to include ApplicationPolicy
      end
    end
  end
end
