module Cheet

  abstract class Document
    @file : File
    @index : Index?

    def initialize(name)
      @file = File.new(name)
    end

    abstract def do_index : Index
    abstract def skip_to_content(heading : Heading)

    def index : Index
      unless idx = @index
        idx = do_index
        @index = idx
      end
      idx.not_nil!
    end

    def content(heading : Int32) : IO
      start_heading = index.headings[heading]
      return IO::Memory.new unless start_heading
      next_heading = index.next_at_level(heading, start_heading.level)
      skip_to_content(start_heading)
      if next_heading
        IO::Sized.new(@file, read_size: next_heading.offset - @file.pos)
      else
        @file
      end
    end
  end

  class Index
    getter headings = [] of Heading

    def to_s(io : IO)
      io << @headings
    end

    def next_at_level(start : Int32, level : UInt8) : Heading?
      next_heading = nil
      # headings = @index.headings.each
      k = start + 1
      while k < headings.size && !next_heading
        kheading = headings[k]
        k += 1
        if kheading.level == level
          next_heading = kheading
        end
      end
      next_heading
    end
  end

  class Heading
    getter value : String
    getter level : UInt8
    getter offset : UInt64

    def initialize(@value, @level, @offset)
    end

    def to_s(io : IO)
      io << "#" * @level << " #{@value} (#{@offset})"
    end

    def inspect(io : IO)
      to_s io
    end
  end

  # Yields every path inside *dirname* and any subdirectories to the block.
  def self.each_child_recursive(dirname : Dir | Path | String)
    parents = Deque({Iterator(String), Path}).new
    case dirname
    in Dir
      topdir = dirname
      toppath = Path[dirname]
    in Path
      topdir = Dir.new(dirname)
      toppath = dirname
    in String
      topdir = Dir.new(dirname)
      toppath = Path[dirname]
    end
    parents.push({topdir.each_child, toppath})
    until parents.empty?
      iter, parent_path = parents.last
      elem = iter.next
      if elem.is_a? Iterator::Stop
        parents.pop
        next
      end
      path = parent_path / elem
      if File.directory? path
        parents.push({Dir.new(path).each_child, path})
        yield path
      elsif File.file? path
        yield path
      end
    end
  end

  # Yields every path inside any directory in *dirs*
  # and any of its subdirectories to the block.
  def self.each_child_recursive(dirs : Array)
    dirs.each do |dir|
      dir = dir.path if dir.is_a? Dir
      each_child_recursive(dir) do |path|
        yield path
      end
    end
  end

  # Yields every regular file inside *dir* and any subdirectories
  # to the block.
  def self.each_file_recursive(dirname : Dir | Path | String)
    each_child_recursive(dirname) do |child|
      yield child if File.file? child
    end
  end
end
