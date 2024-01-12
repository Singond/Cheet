require "option_parser"
require "./lib"

include Cheet
include Cheet::Markdown

module Cheet::Cli
  extend self
  Log = ::Log.for "cheet"

  def parse_args(args)
    area = nil
    topics = [] of Topic
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
        if args.size > 1
          area = parse_area?(args[0])
        end
        topics = area ? args[1..] : args
      end

      p.invalid_option do |opt|
        Log.error { "invalid option: #{opt}" }
        exit 2
      end
    end

    parser.parse(args)
    after.try &.call
    {area, topics, config}
  end

  private def help(io, parser)
    io << parser
    io << "\n"
  end

  private def parse_area?(str : String) : Area?
    if str.includes?('/')
      [Path.new(str)]
    else
      nil
    end
  end

  def main(args = ARGV)
    area, topics, config_args = parse_args(args)
    config = Config.layer(config_args, Config.from_env)
    Cheet.run(area, topics, config)
  end
end

Log.define_formatter Fmt, "#{source}: #{message}"
Log.setup "cheet", :notice, Log::IOBackend.new(STDERR, formatter: Fmt)
Cheet::Cli.main
