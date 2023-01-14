# frozen_string_literal: true

RSpec.describe GitAuto do
  it "has a version number" do
    expect(GitAuto::VERSION).not_to be nil
  end

  let(:ga) { GitAuto.new(__dir__, File.expand_path("~/..")) }
  let(:test_env_fname) { File.expand_path("#{__dir__}/files/test_env") }

  it 'initializes with a list of directories' do
    expect(ga.dirs).to include(__dir__)
    expect(ga.dirs).to include(File.expand_path("~/.."))
  end

  it "reads environment variables from ENV GIT_AUTO_ENV_PATH" do
    expect(ga.getenv['HOME']).to match(/#{ENV['USER']}/)
  end

  it "merges in environment variables from files in GIT_AUTO_ENV_PATH" do
  end
end
