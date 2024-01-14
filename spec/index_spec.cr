require "spec"
require "../src/index"

lorem_index = Cheet::Index.new
lorem_index << Cheet::Heading.new "The Document", 1, 0         # [0]
lorem_index << Cheet::Heading.new "Sed vel lectus", 2, 100     # [1]
lorem_index << Cheet::Heading.new "Quisque porta", 2, 300      # [2]
lorem_index << Cheet::Heading.new "Cras elementum", 3, 400     # [3]
lorem_index << Cheet::Heading.new "Aenean placerat", 2, 450    # [4]
lorem_index << Cheet::Heading.new "Pellentesque arcu", 3, 700  # [5]
lorem_index << Cheet::Heading.new "Aliquam ante", 1, 1000      # [6]
lorem_index << Cheet::Heading.new "Duis risus", 2, 1200        # [7]

describe Cheet::Index do
  describe "#next_at_level" do
    it "returns nil if there is no matching heading" do
      lorem_index.next_at_level(5).should be_nil
      lorem_index.next_at_level(6).should be_nil
      lorem_index.next_at_level(7).should be_nil
    end
    it "returns nil if start heading is out of bounds" do
      lorem_index.next_at_level(10).should be_nil
    end
  end

  describe "#next_above_or_at_level" do
    it "returns nil if there is no matching heading" do
      lorem_index.next_at_level(6).should be_nil
      lorem_index.next_at_level(7).should be_nil
    end
    it "returns nil if start heading is out of bounds" do
      lorem_index.next_at_level(10).should be_nil
    end
  end
end
