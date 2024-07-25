require "colorize"
require "log"
require "./cheet/*"

module Cheet

  def self.load_document(path)
    # TODO: Determine file format, possibly suport other formats
    Markdown::MarkdownDocument.new path
  end

  def self.print_header(document, output = STDOUT, color = :default)
    Colorize.with.fore(color).surround(output) do
      output << document.name << ":"
    end
    output << "\n"
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

  def self.search_topic(document, topic : Topic)
    Log.debug { "Searching topic '#{topic}' in #{document.name}" }
    document.content?(&.matches? topic).try do |content|
      yield topic, content
    end
  end

  def self.search_topics(document, topics : Array)
    topics.each do |topic|
      search_topic document, topic do |topic, content|
        yield topic, content
      end
    end
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

  def self.run(area : Area?, topics : Array(Topic), config = Config.new)
    matches_count = 0
    each_file(area, config) do |path|
      if File.exists? path
        Log.info { "Searching file #{path}..." }
        doc = load_document(path)
        first_topic = true
        search_topics doc, topics do |topic, content|
          config.stdout << "\n" unless matches_count == 0
          if first_topic
            print_header doc, config.stdout, color: config.header_color
            first_topic = false
          end
          print_content content, config.stdout
          matches_count += 1
        end
      end
    end
    matches_count
  end
end
