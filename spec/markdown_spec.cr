require "spec"
require "../src/markdown"

include Cheet::Markdown

describe MarkdownDocument do
  describe "build_index" do
    it "creates an index from headings in the document" do
      d = MarkdownDocument.new("spec/files/lorem.md")
      idx = d.index
      idx.size.should eq 8
      idx[0].value.should eq "The Document"
      idx[0].level.should eq 1
      idx[0].offset.should eq 0
      idx[1].value.should eq "Sed vel lectus"
      idx[1].level.should eq 2
      idx[1].offset.should eq 0xb1
      idx[2].value.should eq "Quisque porta"
      idx[2].level.should eq 2
      idx[2].offset.should eq 0x1f6
      idx[3].value.should eq "Cras elementum"
      idx[3].level.should eq 3
      idx[3].offset.should eq 0x2d0
      idx[4].value.should eq "Aenean placerat"
      idx[4].level.should eq 2
      idx[4].offset.should eq 0x39f
      idx[5].value.should eq "Pellentesque arcu"
      idx[5].level.should eq 3
      idx[5].offset.should eq 0x44b
      idx[6].value.should eq "Aliquam ante"
      idx[6].level.should eq 1
      idx[6].offset.should eq 0x4ec
      idx[7].value.should eq "Duis risus"
      idx[7].level.should eq 2
      idx[7].offset.should eq 0x595
    end
    it "accepts underlined headings syntax (as in setext)" do
      d = MarkdownDocument.new("spec/files/lorem_setext.md")
      idx = d.index
      idx.size.should eq 8
      idx[0].value.should eq "The Document"
      idx[0].level.should eq 1
      idx[0].offset.should eq 0
      idx[1].value.should eq "Sed vel lectus"
      idx[1].level.should eq 2
      idx[1].offset.should eq 0xbc
      idx[2].value.should eq "Aliquet porta"
      idx[2].level.should eq 2
      idx[2].offset.should eq 0x20d
      idx[3].value.should eq "Cras elementum"
      idx[3].level.should eq 3
      idx[3].offset.should eq 0x2f2
      idx[4].value.should eq "Aenean placerat"
      idx[4].level.should eq 2
      idx[4].offset.should eq 0x3c1
      idx[5].value.should eq "Pellentesque arcu"
      idx[5].level.should eq 3
      idx[5].offset.should eq 0x47a
      idx[6].value.should eq "Aliquam ante"
      idx[6].level.should eq 1
      idx[6].offset.should eq 0x51b
      idx[7].value.should eq "Duis risus"
      idx[7].level.should eq 2
      idx[7].offset.should eq 0x5cf
    end
  end

  describe "#content?(Int32)" do
    it "retrieves the content including subsections" do
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

    it "stops at any higher-level heading" do
      d = MarkdownDocument.new("spec/files/lorem.md")
      content = d.content?(3).try &.gets_to_end

      content.should_not be_nil
      content = content.not_nil!

      content.strip.should eq <<-END
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
