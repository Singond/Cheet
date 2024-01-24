require "spec"
require "../src/lib"

include Cheet

describe Cheet do
  describe ".run" do
    it "searches topics in area" do
      config = Config.new
      config.search_path = [Path["spec/files"]]
      config.header_color = :default
      str = String.build do |builder|
        config.stdout = builder
        Cheet.run nil, ["Quisque"], config
      end
      str = str.strip
      lines = str.lines

      lines.size.should eq 11
      lines[0].should contain "lorem.md"
      lines[1].should start_with "Phasellus enim erat"
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
