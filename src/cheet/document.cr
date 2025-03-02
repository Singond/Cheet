require "poor"
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

  # Parses the content of *io* as rich text.
  abstract def parse(io : IO) : Poor::Markup

  # Parses the content of *io* into *builder*.
  abstract def parse(io : IO, builder : Poor::Builder | Poor::Stream)

  def name
    @name
  end

  private def ensure_numbered_index(idx : Index)
    if idx[0]?.try(&.index.nil?)
      idx.number_headings
    end
  end

  def index : Index
    unless idx = @index
      idx = build_index
      ensure_numbered_index(idx)
      @index = idx
    end
    idx.not_nil!
  end

  # Returns the content of the heading given by its index.
  #
  # Returns nil if *heading_index* is out of bounds.
  #
  # If *include heading* is true, the heading itself is included
  # in the returned value, otherwise it is skipped.
  # The default value is `false`.
  def content?(heading_index : Int32, include_heading = false) : IO?
    index[heading_index]?.try do |heading|
      content(heading, include_heading: include_heading)
    end
  end

  # Returns the content of section beginning with *heading*.
  #
  # If given, *heading_index* should be the index of *heading*
  # in this document's index.
  #
  # Raises if *heading* is not present in the index, or not at the position
  # given by *heading_index*.
  protected def content_by_index(heading : Heading,
      heading_index = heading.index, include_heading = false) : IO
    if !heading_index
      heading_index = index.index!(heading)
    elsif heading != index[heading_index]
      # Given *heading_index* is inconsistent with @index
      raise "Heading index does not match heading"
    end
    next_heading = index.next_above_or_at_level(heading_index, heading.level)
    skip_to_content(heading, skip_heading: !include_heading)
    if next_heading
      # Read only to `next_heading`
      IO::Sized.new(@file, read_size: next_heading.offset - @file.pos)
    else
      # Read to end
      @file
    end
  end

  # Returns an iterator that returns the contents of each heading
  # for which the given block is truthy.
  def content?(&func : Heading -> U) forall U
    index.each_with_index
      .select { |heading, heading_index| func.call(heading) }
      .map { |heading, heading_index| content?(heading_index) }
      .reject Nil
  end
end
