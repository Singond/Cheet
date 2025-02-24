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
    document.content?(&.matches? topic).each do |content|
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

  def self.style(config : Config)
    style = Poor::TerminalStyle.new
    style.line_width = 80
    style
  end

  # Searches *topics* in *area* and yields it to the block.
  #
  # The arguments passed to the block are the topic and its content.
  def self.search(area : Area?, topics : Array(Topic), config = Config.new)
    file_idx = 0
    each_file(area, config) do |path|
      if File.exists? path
        Log.info { "Searching file #{path}..." }
        doc = load_document(path)
        topic_idx = 0
        search_topics doc, topics do |topic, content|
          yield topic, content, doc, file_idx, topic_idx
          topic_idx += 1
        end
      end
      file_idx += 1
    end
    # TODO: Fix return value: Return total number of matches
    file_idx
  end

  def self.search_print(area : Area?, topics : Array(Topic), config = Config.new)
    search(area, topics, config) do |topic, content, doc, file_idx, topic_idx|
        if topic_idx == 0
          config.stdout << '\n' if file_idx > 0
          print_header doc, config.stdout, color: config.header_color
        else
          config.stdout << '\n'
        end
        # TODO: Print topic heading (at least if more than one)
        formatter = Poor::TerminalFormatter.new(style(config), config.stdout)
        doc.parse(content, Poor::Stream.new(formatter))
        config.stdout << '\n'
    end
  end

  def self.run(area, topics, config)
    search_print(area, topics, config)
  end
end
