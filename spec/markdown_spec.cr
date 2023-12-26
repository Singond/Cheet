require "spec"
require "../src/markdown"

include Cheet
include Cheet::Markdown

describe MarkdownDocument do
  describe "#content?(Int32)" do
    it "retrieves the content under a heading" do
      d = MarkdownDocument.new("spec/files/lorem.md")
      content = d.content?(2).try &.gets_to_end

      content.should_not be_nil
      content = content.not_nil!

      content.strip.should eq <<-END
      Phasellus enim erat, vestibulum vel, aliquam a, posuere eu, velit:
          - Ut enim ad minim veniam,
          - quis nostrud exercitation,
          - ullamco laboris nisi
          - ut aliquip ex ea commodo consequat.

      ### Cras elementum
      Mauris dolor felis, sagittis at, luctus sed, aliquam non, tellus.
      Integer rutrum, orci vestibulum ullamcorper ultricies, lacus quam
      ultricies odio, vitae placerat pede sem sit amet enim.
      END
    end
  end

  describe "#content?(Topic)" do
    it "retrieves the content under a heading" do
      d = MarkdownDocument.new("spec/files/lorem.md")
      content = (d.content? &.value.includes?("lectus")).try &.gets_to_end

      content.should_not be_nil
      content = content.not_nil!

      content.strip.should eq <<-END
      Donec odio tempus molestie, porttitor ut, iaculis quis, sem.
      Etiam ligula pede, sagittis quis, interdum ultricies, scelerisque eu.
      Aliquam in lorem sit amet leo accumsan lacinia.

      In sem justo, commodo ut, suscipit at, pharetra vitae, orci.
      Fusce dui leo, imperdiet in, aliquam sit amet, feugiat eu, orci.
      END
    end
  end
end
