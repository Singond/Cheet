require "spec"
require "../src/cheet/config"

include Cheet

describe Cheet::Config do
  describe ".load_env" do
    it "loads path from environment variable" do
      config = Config.from_env({
        "CHEET_PATH" => "/home/user/cheatsheets:/home/user/.cheet"
      })
      config.search_path.should eq [
        Path["/home/user/cheatsheets"],
        Path["/home/user/.cheet"]
      ]
    end

    it "sets path to empty if environment variable is defined but empty" do
      config = Config.from_env({"CHEET_PATH" => ""})
      config.search_path.should eq [] of Path
    end

    it "sets path to default if environment variable is undefined" do
      config = Config.from_env(Hash(String, String).new)
      config.search_path.should eq [
        Path.home / ".local/share/cheet",
        Path.home / ".cheet"
      ]
    end
  end

  describe ".layer" do
    it "copies the attribute of the first object where it is non-nil" do
      cfg1 = Config.new
      cfg1.stdout = STDERR
      cfg1.search_path = nil
      cfg1.promote_headings = false
      cfg2 = Config.new
      cfg2.stdout = STDOUT
      cfg2.search_path = [Path["/home/user/"]]
      cfg2.promote_headings = true
      layered = Config.layer(cfg1, cfg2)
      layered.stdout.should eq STDERR
      layered.search_path.should eq [Path["/home/user/"]]
      layered.promote_headings.should eq false
    end
  end
end
