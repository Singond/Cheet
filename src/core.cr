module Cheet

  VERSION = {{ `shards version #{__DIR__}`.chomp.stringify }}
  BUILD_DATE = {{ `date -u -I`.chomp.stringify }}
  REVISION = {{ env("CHEET_GIT_COMMIT") }}

  Log = ::Log.for "cheet"

  alias Area = Array(Path)
  alias Topic = String

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

    # Returns the content of the heading given by its index.
    def content?(heading : Int32) : IO?
      start_heading = index.headings[heading]
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
      heading_index = index.headings.index do |heading|
        yield heading
      end
      heading_index.try do |idx|
        content?(idx)
      end
    end
  end

  class Index
    getter headings = [] of Heading

    def to_s(io : IO)
      io << @headings
    end

    def next_at_level(start : Int32, level = level_of(start)) : Heading?
      headings.each
          .skip(start + 1)
          .select { |heading| heading.level == level }
          .first?
    end

    def next_above_or_at_level(start : Int32, level = level_of(start)) : Heading?
      headings.each
          .skip(start + 1)
          .select { |heading| heading.level <= level }
          .first?
    end

    private def level_of(index)
      @headings[index]?.try &.level
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
  def self.each_child_recursive(dirname : Dir | Path | String,
      skip_hidden = true)
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
      next if skip_hidden && elem.starts_with? "."
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
      next unless dir.is_a? Dir || File.directory? dir
      each_child_recursive(dir) do |path|
        yield path
      end
    end
  end

  # Yields every regular file inside *dir* and any subdirectories
  # to the block.
  # The argument can also be an array of directories.
  def self.each_file_recursive(dir)
    each_child_recursive(dir) do |child|
      yield child if File.file? child
    end
  end

  # Prints version information into *io*.
  #
  # The information printed includes the program version and the date
  # it was built.
  #
  # If a configuration object is given and the log level is higher than
  # `Notice`, it includes additional information like the corresponding
  # Git commit hash (provided it was available at compile time).
  def print_version(io = STDOUT, revision = false)
    io << "Cheet "
    io << VERSION
    io << " ("
    io << BUILD_DATE
    io << ")\n"
    if revision && (rev = REVISION) && !rev.empty?
      io << "git revision: #{REVISION}\n"
    end
  end
end
