require "option_parser"
require "./lib"

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
    {positional_args, config}
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
      [Path.new(str)]
    else
      nil
    end
    Log.info { "Area is #{area ? area.join(", ") : "nil"}" }
    area
  end

  def main(args = ARGV)
    posargs, config_args = parse_args(args)
    config_env = Config.from_env
    Log.debug { "Merging configuration from arguments and environment" }
    config = Config.layer(config_args, config_env)
    Log.debug { "Path is #{config.search_path.map(&.to_s).join(":")}" }
    area, topics = split_positional_args(posargs, config.search_path)
    Cheet.run(area, topics, config)
  end
end

Log.define_formatter Fmt, "#{source}: #{message}"
Log.setup "cheet", :notice,
    Log::IOBackend.new(STDERR, formatter: Fmt, dispatcher: :sync)
Cheet::Cli.main
