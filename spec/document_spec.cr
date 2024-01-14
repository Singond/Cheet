require "spec"
require "../src/document"

class TestDocument < Cheet::Document

  def initialize
    @file = File.tempfile
  end

  def build_index : Cheet::Index
    index = Cheet::Index.new
    index << Cheet::Heading.new "The Document", 1, 0         # [0]
    index << Cheet::Heading.new "Sed vel lectus", 2, 100     # [1]
    index << Cheet::Heading.new "Quisque porta", 2, 300      # [2]
    index << Cheet::Heading.new "Cras elementum", 3, 400     # [3]
    index << Cheet::Heading.new "Aenean placerat", 2, 450    # [4]
    index << Cheet::Heading.new "Pellentesque arcu", 3, 700  # [5]
    index << Cheet::Heading.new "Aliquam ante", 1, 1000      # [6]
    index << Cheet::Heading.new "Duis risus", 2, 1200        # [7]
    index
  end

  def skip_to_content(heading)
  end
end

describe Cheet::Document do
  describe "#content(heading)?" do
    it "returns nil if the heading is out of bounds" do
      testdoc = TestDocument.new
      testdoc.content?(12).should be_nil
    end
  end
end
