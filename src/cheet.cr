require "colorize"
require "log"
require "./cheet/*"

module Cheet

  def self.load_document(path)
    # TODO: Determine file format, possibly suport other formats
    Markdown::MarkdownDocument.new path
  end

  struct Match
    getter document : Document
    getter topic : Topic
    getter heading : Heading

    def initialize(@document, @topic, @heading)
    end

    def content : IO
      document.content(heading, include_heading: true)
    end

    def parse_content(builder)
      document.parse(content, builder)
    end
  end

  # Searches *topics* in *area* and yields matches to the block.
  def self.search(area : Area?, topics : Array(Topic), config = Config.new)
    each_file(area, config) do |path|
      if File.exists? path
        Log.info { "Searching file #{path}..." }
        doc = load_document(path)
        topics.each do |topic|
          doc.select_headings(&.matches? topic).each do |heading|
            yield Match.new(doc, topic, heading)
          end
        end
      end
    end
  end

  # Searches *topics* in *area* and returns an array of the matches.
  def self.search(area : Area?, topics : Array(Topic), config = Config.new)
    matches = [] of Match
    search(area, topics, config) do |match|
      matches << match
    end
    matches
  end

  def self.print_header(document, output = STDOUT, color = :default)
    Colorize.with.fore(color).surround(output) do
      output << document.name << ':'
    end
    output << '\n'
  end

  def self.print_same_file_separator(output = STDOUT, color = :default)
    output << '\n'
  end

  def self.print_content(content, output = STDOUT)
    skip_whitespace content, output
    IO.copy content, output
  end

  private def self.skip_whitespace(input, output)
    while (c = input.read_char) && c.whitespace?
      # skip
    end
    output << c if c
  end

  def self.each_file(area : Area?, config = Config.new)
    if area
      Log.info { "Area given, processing only matching files" }
      area.each do |path|
        yield path
      end
    else
      Log.info { "No area given, processing all files in path" }
      each_file_recursive config.search_path do |path|
        Log.trace { "Processing #{path}" }
        yield path
      end
    end
  end

  def self.style(config : Config)
    style = Poor::TerminalStyle.new
    style.line_width = 80
    style.left_margin = 4
    style.right_margin = 4
    style.code_style = Colorize.with.dim
    style
  end

  # Searches for *topics* in *area* and prints matching sections.
  #
  # Returns the number of matches.
  def self.search_print(area : Area?, topics : Array(Topic), config = Config.new)
    matches = search(area, topics, config)
    last_document : Document? = nil
    matches.each do |match|
      unless match.document == last_document
        print_header(match.document, config.stdout, color: config.header_color)
      else
        print_same_file_separator(config.stdout, color: config.header_color)
      end
      formatter = Poor::TerminalFormatter.new(style(config), config.stdout)
      match.parse_content(Poor::Stream.new(formatter))
      config.stdout << '\n'
      last_document = match.document
    end
    matches.size
  end

  def self.run(area, topics, config) : Int32
    search_print(area, topics, config)
  end
end
