require "poor/markdown"
require "./core"
require "./document"
require "./parsing"
require "./two_line_iterator"

include Poor

module Cheet::Markdown

  class MarkdownDocument < Document

    def initialize(name)
      super(name)
    end

    def build_index : Index
      idx = Index.new
      @file.seek(0)
      TwoLineIterator.new(@file).each do |line, offset, next_line|
        heading = Cheet.atx_heading(line, offset)
        heading ||= Cheet.setext_heading({line, next_line}, offset)
        idx << heading if heading
      end
      idx
    end

    def skip_to_content(heading : Heading, *, skip_heading = true)
      @file.seek(heading.offset)
      if skip_heading
        heading = @file.gets
        unless heading && heading.lstrip.starts_with? '#'
          # Skip underline
          @file.gets
        end
      end
    end

    def parse(io : IO) : Poor::Markup
      builder = Poor::Builder.new
      parse(io, builder)
      builder.get
    end

    def parse(io : IO, builder : Poor::Builder | Poor::Stream)
      Poor::Markdown.parse(io, builder)
    end
  end
end
