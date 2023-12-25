require "spec"
require "../src/core"

include Cheet

describe Cheet do
  describe ".each_child_recursive" do
    it "yields every path in any subdirectory" do
      paths = [] of String
      Cheet.each_child_recursive "spec" do |path|
        paths << path.to_s
      end

      paths.should contain "spec/files"
      paths.should contain "spec/files/lorem.md"
      paths.should contain "spec/core_spec.cr"
      paths.should contain "spec/markdown_spec.cr"
      paths.should_not contain "src/core.cr"
      paths.should_not contain "src/markdown.cr"
    end
  end

  describe ".each_child_recursive(Array)" do
    it "yields every path in any subdirectory" do
      paths = [] of String
      Cheet.each_child_recursive ["spec", "src"] do |path|
        paths << path.to_s
      end

      paths.should contain "spec/files"
      paths.should contain "spec/files/lorem.md"
      paths.should contain "spec/core_spec.cr"
      paths.should contain "spec/markdown_spec.cr"
      paths.should contain "src/core.cr"
      paths.should contain "src/markdown.cr"
    end
  end

  describe ".each_file_recursive" do
    it "yields every regular file in any subdirectory" do
      paths = [] of String
      Cheet.each_file_recursive "spec" do |path|
        paths << path.to_s
      end

      paths.should_not contain "spec/files"
      paths.should contain "spec/files/lorem.md"
      paths.should contain "spec/core_spec.cr"
      paths.should contain "spec/markdown_spec.cr"
      paths.should_not contain "src/core.cr"
      paths.should_not contain "src/markdown.cr"
    end

    it "accepts array argument" do
      paths = [] of String
      Cheet.each_file_recursive ["spec", "src"] do |path|
        paths << path.to_s
      end

      paths.should_not contain "spec/files"
      paths.should contain "spec/files/lorem.md"
      paths.should contain "spec/core_spec.cr"
      paths.should contain "spec/markdown_spec.cr"
      paths.should contain "src/core.cr"
      paths.should contain "src/markdown.cr"
    end
  end

end
