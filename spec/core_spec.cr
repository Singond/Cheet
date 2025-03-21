require "spec"
require "../src/cheet/core"

include Cheet
include Poor

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
      paths.should contain "src/cheet/core.cr"
      paths.should contain "src/cheet/markdown.cr"
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
      paths.should_not contain "src/cheet/core.cr"
      paths.should_not contain "src/cheet/markdown.cr"
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
      paths.should contain "src/cheet/core.cr"
      paths.should contain "src/cheet/markdown.cr"
    end
  end

  describe ".promote_headings" do
    it "changes the level of headings so that the first is level one" do
      m = markup(
        heading(2, "Lorem ipsum"),
        heading(2, "Sed vel lectus"),
        heading(3, "Quisque porta"),
        heading(4, "Cras elementum"),
        heading(4, "Aenean placerat"),
        heading(3, "Pellentesque arcu"),
        heading(2, "Aliquam ante")
      )
      promoted = Cheet.promote_headings(m)
      promoted[0].should be_a Heading
      promoted[0].as(Heading).level.should eq 1
      promoted[1].as(Heading).level.should eq 1
      promoted[2].as(Heading).level.should eq 2
      promoted[3].as(Heading).level.should eq 3
      promoted[4].as(Heading).level.should eq 3
      promoted[5].as(Heading).level.should eq 2
      promoted[6].as(Heading).level.should eq 1
    end
  end
end
