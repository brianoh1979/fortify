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

  describe "#activate!" do
    context 'when activate! is not called' do
      it 'does not apply Fortify' do
        expect{User.safe}.to raise_error(NoMethodError)
      end
    end

    context 'when activate! is called' do
      let(:current_user) { User.find_by(name: 'default-user') }

      it 'applies Fortify' do
        Fortify.activate!
        Fortify.user = current_user
        expect(User.safe.size).to eq 1
      end
    end
  end

  describe "policies" do
    let(:current_user) { User.find_by(name: 'default-user') }

    before do
      Fortify.activate!
      Fortify.user = current_user
    end

    context 'applying scope' do
      it 'scopes' do
        safe_project = Project.safe
        expect(safe_project.size).to eq 1
        expect(safe_project.first.id).to eq current_user.project_ids.first
      end
    end

    context 'applying validation' do
      it 'allows permitted actions' do
        project = Project.safe.first
        expect(project.update_attributes(name: 'ver2')).to eq true
      end

      it 'does not allow unpermitted actions' do
        project = Project.safe.first
        expect(project.destroy).to eq false
      end
    end
  end
end
