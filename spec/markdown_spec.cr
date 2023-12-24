require "spec"
require "../src/markdown"

include Cheet
include Cheet::Markdown

describe MarkdownDocument do
  describe "#content" do
    it "retrieves the content under a heading" do
      d = MarkdownDocument.new("spec/files/lorem.md")
      content = d.content(2).gets_to_end
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
end
