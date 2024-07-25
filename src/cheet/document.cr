require "./index"

abstract class Cheet::Document
  @file : File
  @index : Index?

  def initialize(@name : Path | String)
    @file = File.new(name)
  end

  # Builds the index of headings in this document.
  abstract def build_index : Index

  # Seeks within the underlying file the content immediately after
  # *heading*.
  #
  # This method should not be called by clients directly.
  abstract def skip_to_content(heading : Heading)

  def name
    @name
  end

  def index : Index
    unless idx = @index
      idx = build_index
      @index = idx
    end
    idx.not_nil!
  end

  # Returns the content of the heading given by its index.
  #
  # Returns nil if *heading_index* is out of bounds.
  def content?(heading_index : Int32) : IO?
    heading = index[heading_index]?
    heading ? content_by_index(heading, heading_index) : nil
  end

  # Returns the content of *heading*.
  #
  # If given, *heading_index* should be the index of *heading*
  # in this document's index.
  protected def content_by_index(heading : Heading, heading_index = nil) : IO
    if !heading_index
      heading_index = index.index!(heading)
    elsif heading != index[heading_index]
      # Given *heading_index* is inconsistent with @index
      raise "Heading index does not match heading"
    end
    next_heading = index.next_above_or_at_level(heading_index, heading.level)
    skip_to_content(heading)
    if next_heading
      # Read only to `next_heading`
      IO::Sized.new(@file, read_size: next_heading.offset - @file.pos)
    else
      # Read to end
      @file
    end
  end

  # Returns the content of the first heading for which the given block
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
