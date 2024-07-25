module Cheet

  VERSION = {{ `shards version #{__DIR__}`.chomp.stringify }}
  BUILD_DATE = {{ `date -u -I`.chomp.stringify }}
  REVISION = {{ env("CHEET_GIT_COMMIT") }}

  Log = ::Log.for "cheet"

  alias Area = Array(Path)
  alias Topic = String

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
