require "option_parser"
require "./cheet"

include Cheet
include Cheet::Markdown

module Cheet::Cli
  extend self
  Log = ::Log.for "cheet"

  def parse_args(args)
    positional_args = [] of String
    config = Config.new
    after = nil

    parser = OptionParser.new do |p|
      p.banner = <<-USAGE
      Usage: cheet [AREA] [TOPIC...]

      Options:
      USAGE

      p.on "-h", "--help", "Show help and exit" do
        help(STDOUT, p)
        exit 0
      end

      p.on "-v", "--verbose", "Increase verbosity" do
        current_level = Log.level
        if current_level > ::Log::Severity::Trace
          Log.level = current_level - 1
          Log.debug { "Log level set to #{Log.level}" }
        end
      end

      p.on "--version", "Print version information" do
        # Delay execution until after all arguments are parsed
        # to account for later options (specifically --verbose).
        after = -> {
          print_version(STDOUT, Log.level <= ::Log::Severity::Info)
          exit 0
        }
      end

      p.unknown_args do |args|
        positional_args = args
      end

      p.invalid_option do |opt|
        Log.error { "invalid option: #{opt}" }
        exit 2
      end
    end

    parser.parse(args)
    after.try &.call
    {positional_args, config, parser}
  end

  private def help(io, parser)
    io << parser
    io << "\n"
  end

  private def split_positional_args(args, search_path)
    if args.size > 1
      search_path |= [] of Path
      area = parse_area?(args[0], search_path)
    end
    topics = area ? args[1..] : args
    {area, topics}
  end

  private def parse_area?(str : String, search_path) : Area?
    Log.info { "Parsing area..." }
    if str.includes?('/')
      area = [Path.new(str)]
    else
      matching = [] of Path
      str = str.downcase
      Log.info { "Searching files matching '#{str}'" }
      search_path.each do |dir|
        unless File.directory? dir
          Log.debug { "#{dir} does not exist" }
          next
        end
        Log.debug { "Searching in #{dir}" }
        Cheet.each_file_recursive(dir) do |path|
          Log.debug { "Trying #{path}" }
          if path.basename.downcase.includes? str
            Log.debug { "Found #{path}" }
            matching << path
          end
        end
      end
      area = matching unless matching.empty?
    end
    Log.info { "Area is #{area ? area.join(", ") : "nil"}" }
    area
  end

  def main(args = ARGV)
    posargs, config_args, parser = parse_args(args)
    if args.empty?
      help STDOUT, parser
      exit 2
    end
    config_env = Config.from_env
    Log.debug { "Merging configuration from arguments and environment" }
    config = Config.layer(config_args, config_env)
    Log.debug { "Path is #{config.search_path.map(&.to_s).join(":")}" }
    area, topics = split_positional_args(posargs, config.search_path)
    count = Cheet.run(area, topics, config)
    exit 1 if count == 0
  end
end

Log.define_formatter Fmt, "#{source}: #{message}"
Log.setup "cheet", :notice,
    Log::IOBackend.new(STDERR, formatter: Fmt, dispatcher: :sync)
Cheet::Cli.main
