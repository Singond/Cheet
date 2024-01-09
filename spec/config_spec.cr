require "spec"
require "../src/config"

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
end
