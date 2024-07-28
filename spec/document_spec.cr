require "spec"
require "../src/cheet/document"

class TestDocument < Cheet::Document

  def initialize(@index)
    @name = "test document"
    @file = File.tempfile
  end

  def build_index : Cheet::Index
    @index.not_nil!
  end

  def skip_to_content(heading)
  end

  def public_content_by_index(*args)
    content_by_index *args
  end
end

def loremdoc
  TestDocument.new(Cheet::Index.new.tap { |index|
    index << Cheet::Heading.new "The Document", 1, 0         # [0]
    index << Cheet::Heading.new "Sed vel lectus", 2, 100     # [1]
    index << Cheet::Heading.new "Quisque porta", 2, 300      # [2]
    index << Cheet::Heading.new "Cras elementum", 3, 400     # [3]
    index << Cheet::Heading.new "Aenean placerat", 2, 450    # [4]
    index << Cheet::Heading.new "Pellentesque arcu", 3, 700  # [5]
    index << Cheet::Heading.new "Aliquam ante", 1, 1000      # [6]
    index << Cheet::Heading.new "Duis risus", 2, 1200        # [7]
  })
end

describe Cheet::Document do
  describe "#content(heading)?" do
    it "returns nil if the heading is out of bounds" do
      loremdoc.content?(12).should be_nil
    end
  end

  describe "#content_by_index" do
    it "raises if *heading_index* does not match *heading*" do
      expect_raises(Exception, /index does not match/) do
        loremdoc.public_content_by_index(loremdoc.index[2], 4)
      end
    end
  end
end
