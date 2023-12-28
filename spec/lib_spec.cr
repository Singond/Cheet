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
  end
end
