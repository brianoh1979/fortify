require "spec_helper"

RSpec.describe Fortify do
  it "has a version number" do
    expect(Fortify::VERSION).not_to be nil
  end

  skip "does something useful" do
    expect(false).to eq(true)
  end
end
