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
      expect(Fortify.insecurely { Project.count }).to be 2
    end

    it "loads models and associations properly" do
      Fortify.insecurely do
        expect(User.find_by(name: "default-user").projects.first.name).to eq "Default Project"
        expect(User.find_by(name: "default-user").projects.first.tasks.first.name).to eq "Default Task"
      end
    end
    it "loads policies properly" do
      [UserPolicy, TaskPolicy, ProjectPolicy].each do |policy|
        expect(policy.ancestors).to include Fortify::Base
      end
    end
  end

  describe "#activate!" do
    context 'when activate! is called' do
      let(:current_user) { Fortify.insecurely { User.find_by(name: 'default-user') } }

      it 'applies Fortify' do
        Fortify.set_user(current_user)
        expect(User.count).to eq 1
      end
    end

    context "when activate! is called but a user is never set" do
      it "should throw an error" do
        Fortify.user = nil
        expect { User.all }.to raise_error(Fortify::InvalidUser).with_message("Fortify user not set")
      end
    end
  end

  describe "policies" do
    let(:current_user) { Fortify.insecurely { User.find_by(name: 'default-user') } }

    before do
      Fortify.set_user(current_user)
    end

    context 'applying scope' do
      it 'scopes' do
        project = Project.all
        expect(project.size).to eq 1
        expect(project.first.id).to eq current_user.project_ids.first
      end

      it 'scopes associations' do
        project = Project.first
        expect(project.tasks.count).to eq 2
      end
    end

    context '#permitted_attributes_for_read' do
      it 'cannot read unreadable attributes' do
        project = Project.first
        expect(project.can?(:read, :created_at)).to eq false
        expect(project.can?(:read, :text)).to eq true
      end
    end

    context 'applying validation' do
      it 'allows permitted actions' do
        project = Project.first

        expect(project.can?(:update, :name)).to eq true
        project.name = 'ver2'
        expect(project.valid?).to eq true
      end

      it 'does not allow unpermitted updates' do
        project = Project.first

        expect(project.can?(:update, :created_at)).to eq false
        project.created_at = DateTime.now
        expect(project.valid?).to eq false
        expect(project.errors.first[0]).to eq :created_at
        expect(project.errors.first[1]).to eq "You are not authorizated to perform this action"
      end

      it 'does not allow unpermitted destroys' do
        project = Project.first
        expect(project.destroy).to eq false
      end

      context 'when the user can perform destroy' do
        let(:current_user) { Fortify.insecurely { User.find_by(name: 'admin-user') } }

        it 'allows destroying' do
          project = Project.first
          expect(project.can?(:destroy)).to eq true
        end
      end
    end
  end

  describe "scoping" do
    let(:current_user) { Fortify.insecurely { User.find_by(name: 'default-user') } }
    let(:partner_user) { Fortify.insecurely { User.find_by(name: 'partner-user') } }

    before do
      Fortify.set_user(current_user)
    end
    context "default scope" do
      it "should be active on everything but create" do
        expect { User.create! }.to change { Fortify.insecurely { User.count } }.by 1
      end

      it "should not set default scope attributes on new records" do
        user = User.create!
        expect(user.id).to_not eq current_user.id
      end

      it "should not affect initializing objects from the database" do
        expect(Task.count).to eq 2
        expect(Project.first.tasks.count).to eq 2
      end

      context "querying the database" do
        before { Fortify.insecurely { Fortify.set_user(partner_user) } }

        it "should limit via scope" do
          expect(partner_user.projects.first.tasks.count).to eq 1
          expect(partner_user.tasks.count).to eq 0
        end
      end
    end
  end
end
