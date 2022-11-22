# frozen_string_literal: true

RSpec.describe GitAuto do
  it "has a version number" do
    expect(GitAuto::VERSION).not_to be nil
  end

  let(:ga) { GitAuto.new("~/src/fat_core", "~/src/fat_period") }

  it 'initializes with a list of directories' do
    expect(ga.dirs).to include("/home/ded/src/fat_core")
    expect(ga.dirs).to include("/home/ded/src/fat_period")
  end

  it "reads environment variables from ENV GIT_AUTO_ENV_PATH" do
    expect(ga.getenv['HOME']).to match(/ded/)
  end

  it "merges in environment variables from files in GIT_AUTO_ENV_PATH" do
  end
end
