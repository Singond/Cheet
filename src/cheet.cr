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

    parser = OptionParser.new do |p|
      p.banner = <<-USAGE
      Usage: cheet [AREA] [TOPIC...]

      Options:
      USAGE

      p.on "-h", "--help", "Show help and exit" do
        help(STDOUT, p)
      end

      p.on "-v", "--verbose", "Increase verbosity" do
        current_level = Log.level
        if current_level > ::Log::Severity::Trace
          Log.level = current_level - 1
          Log.debug { "Log level set to #{Log.level}" }
        end
      end

      p.unknown_args do |args|
        if args.size > 1
          area = parse_area?(args[0])
        end
        topics = area ? args[1..] : args
      end
    end

    parser.parse(args)
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
