require "spec_helper"

RSpec.describe Fortify do
  around(:each) do |example|
    Fortify.user = nil
    Fortify.enabled!
    example.run
    Fortify.disabled!
    Fortify.user = nil
  end

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
        expect(policy.ancestors).to include Fortify::Base
      end
    end
  end

  describe "#activate!" do
    context 'when activate! is called' do
      let(:default_user) { User.find_by(name: 'default-user') }

      it 'applies Fortify' do
        Fortify.user = default_user
        expect(User.fortified.count).to eq 1
      end
    end

    context "when activate! is called but a user is never set" do
      it "should throw an error" do
        Fortify.user = nil
        expect { User.fortified.all }.to raise_error(Fortify::InvalidUser).with_message("Fortify user not set")
      end
    end
  end

  describe "#insecurely" do
    it "doesn't change whether fortify is enabled outside the block" do
      Fortify.enabled = false
      Fortify.insecurely do
        expect(Fortify).not_to be_enabled
        Fortify.enabled = true
        Fortify.insecurely do
          expect(Fortify).not_to be_enabled
        end
        expect(Fortify).to be_enabled
      end
      expect(Fortify).not_to be_enabled
    end
  end

  describe "policies" do
    let(:default_user) { User.find_by(name: 'default-user') }
    let(:other_user) { User.find_by(name: 'other-user') }

    before do
      Fortify.user = default_user
    end

    context 'applying scope' do
      it 'scopes' do
        project = Project.fortified.all
        expect(project.size).to eq 1
        expect(project.first.id).to eq default_user.project_ids.first
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

      it 'does not allow updates for unauthorized resources' do
        expect(default_user.can?(:update)).to be true
        expect(other_user.can?(:update)).not_to be true
      end

      it 'does not allow unpermitted destroys' do
        project = Project.first
        expect(project.destroy).to eq false
      end

      context 'when the user can perform destroy' do
        let(:admin_user) { User.find_by(name: 'admin-user') }

        it 'allows destroying' do
          Fortify.user = admin_user

          project = Project.first
          expect(project.can?(:destroy)).to eq true
        end
      end
    end
  end

  describe "scoping" do
    let(:current_user) { Fortify.insecurely { User.find_by(name: 'default-user') } }
    let(:partner_user) { Fortify.insecurely { User.find_by(name: 'partner-user') } }

    context "fortified scope" do
      it "should not affect initializing objects from the database" do
        Fortify.user = current_user

        expect(Task.fortified.count).to eq 2
        expect(Project.first.tasks.fortified.count).to eq 2
      end

      context "querying the database" do
        it "should limit via scope" do
          Fortify.user = partner_user

          expect(Task.fortified.count).to eq 1
          expect(partner_user.tasks.fortified.count).to eq(1)
        end
      end
    end
  end
end
