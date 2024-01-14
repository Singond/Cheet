require "./index"

abstract class Cheet::Document
  @file : File
  @index : Index?

  def initialize(name)
    @file = File.new(name)
  end

  # Builds the index of headings in this document.
  abstract def build_index : Index

  # Seeks within the underlying file the content immediately after
  # *heading*.
  #
  # This method should not be called by clients directly.
  abstract def skip_to_content(heading : Heading)

  def index : Index
    unless idx = @index
      idx = build_index
      @index = idx
    end
    idx.not_nil!
  end

  # Returns the content of the heading given by its index.
  def content?(heading : Int32) : IO?
    start_heading = index[heading]?
    return nil unless start_heading
    next_heading = index.next_above_or_at_level(heading, start_heading.level)
    skip_to_content(start_heading)
    if next_heading
      # Read only to `next_heading`
      IO::Sized.new(@file, read_size: next_heading.offset - @file.pos)
    else
      # Read to end
      @file
    end
  end

  # Returns the content of the heading for which the given block
  # is truthy.
  def content? : IO?
    heading_index = index.index do |heading|
      yield heading
    end
    heading_index.try do |idx|
      content?(idx)
    end
  end
end
