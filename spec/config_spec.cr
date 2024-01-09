require "spec"
require "../src/config"

include Cheet

describe Cheet::Config do
  describe ".load_env" do
    it "loads path from environment variable" do
      config = Config.new
      config.load_env({
        "CHEET_PATH" => "/home/user/cheatsheets:/home/user/.cheet"
      })
      config.search_path.should eq [
        Path["/home/user/cheatsheets"],
        Path["/home/user/.cheet"]
      ]
    end

    it "defaults to original value if environment variable is empty" do
      config = Config.new
      config.load_env({"CHEET_PATH" => ""})
      config.search_path.should eq [
        Path.home / ".local/share/cheet",
        Path.home / ".cheet"
      ]
    end

    it "defaults to original value if environment variable is undefined" do
      config = Config.new
      config.load_env(Hash(String, String).new)
      config.search_path.should eq [
        Path.home / ".local/share/cheet",
        Path.home / ".cheet"
      ]
    end
  end
end
