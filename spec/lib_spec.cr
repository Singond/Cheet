require "spec"
require "../src/lib"

include Cheet

describe Cheet do
  describe ".run" do
    it "searches topics in area" do
      config = Config.new
      config.search_path = [Path["spec/files"]]
      str = String.build do |builder|
        config.stdout = builder
        Cheet.run nil, ["Quisque"], config
      end
      str = str.strip
      lines = str.lines

      str.should start_with "Phasellus enim erat"
      str.lines.size.should eq 10
      str.should contain "### Cras elementum"
      str.should end_with "vitae placerat pede sem sit amet enim."
    end

    it "ignores hidden directories" do
      config = Config.new
      config.search_path = [Path["spec/files"]]
      str = String.build do |builder|
        config.stdout = builder
        Cheet.run nil, ["Quisque"], config
      end

      str.should contain "Phasellus enim erat"
      str.should_not contain "This should never appear in output"
    end
  end
end

describe Cheet::Config do
  describe "#load_env" do
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
