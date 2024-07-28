require "spec"
require "../src/cheet/parsing"

describe ".consists_only_of" do
  it "returns true if string consists entirely of *char*" do
    Cheet.consists_only_of?("AAAAAA", 'A').should be_true
  end
  it "returns false if string contains characters other than *char*" do
    Cheet.consists_only_of?("BAAAAA", 'A').should be_false
    Cheet.consists_only_of?("AABAAA", 'A').should be_false
    Cheet.consists_only_of?("AAAAAB", 'A').should be_false
  end
end

describe ".setext_heading" do
  it "parses a level one heading" do
    lines = <<-LINES
      Lorem Ipsum
      ===========
      LINES
    heading = Cheet.setext_heading(lines.each_line.to_a)
    heading.should be_a Cheet::Heading
    heading = heading.not_nil!
    heading.value.should eq "Lorem Ipsum"
    heading.level.should eq 1
  end
  it "parses a level two heading" do
    lines = <<-LINES
      Lorem Ipsum
      -----------
      LINES
    heading = Cheet.setext_heading(lines.each_line.to_a)
    heading.should be_a Cheet::Heading
    heading = heading.not_nil!
    heading.value.should eq "Lorem Ipsum"
    heading.level.should eq 2
  end
  it "parses a level three heading" do
    lines = <<-LINES
      Lorem Ipsum
      ~~~~~~~~~~~
      LINES
    heading = Cheet.setext_heading(lines.each_line.to_a)
    heading.should be_a Cheet::Heading
    heading = heading.not_nil!
    heading.value.should eq "Lorem Ipsum"
    heading.level.should eq 3
  end
  it "parses a level four heading" do
    lines = <<-LINES
      Lorem Ipsum
      ^^^^^^^^^^^
      LINES
    heading = Cheet.setext_heading(lines.each_line.to_a)
    heading.should be_a Cheet::Heading
    heading = heading.not_nil!
    heading.value.should eq "Lorem Ipsum"
    heading.level.should eq 4
  end
  it "parses a level five heading" do
    lines = <<-LINES
      Lorem Ipsum
      +++++++++++
      LINES
    heading = Cheet.setext_heading(lines.each_line.to_a)
    heading.should be_a Cheet::Heading
    heading = heading.not_nil!
    heading.value.should eq "Lorem Ipsum"
    heading.level.should eq 5
  end
  it "ignores underline followed by other characters" do
    lines = <<-LINES
      Lorem Ipsum
      =========== This is not a heading
      LINES
    heading = Cheet.setext_heading(lines.each_line.to_a)
    heading.should be_nil
  end
end
