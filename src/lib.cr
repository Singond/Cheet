require "log"
require "./core"
require "./config"
require "./document"
require "./markdown"

module Cheet

  def self.load_document(path)
    # TODO: Determine file format, possibly suport other formats
    Markdown::MarkdownDocument.new path
  end

  def self.print_topic(document, topic : Topic, output = STDOUT)
    Log.debug { "Searching topic '#{topic}' in #{document}" }
    document.content?(&.matches? topic).try do |content|
      IO.copy content, output
    end
  end

  def self.print_topics(document, topics : Array, output = STDOUT)
    topics.each do |topic|
      print_topic document, topic, output
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
      Log.debug { "path is #{config.search_path.map(&.to_s).join(":")}" }
      each_file_recursive config.search_path do |path|
        Log.trace { "Processing #{path}" }
        yield path
      end
    end
  end

  def self.run(area : Area?, topics : Array(Topic), config = Config.new)
    each_file(area, config) do |path|
      if File.exists? path
        Log.info { "Searching file #{path}" }
        print_topics load_document(path), topics, config.stdout
      end
    end
  end
end
