require "./core"
require "./document"
require "./parsing"
require "./two_line_iterator"

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

    def skip_to_content(heading : Heading)
      @file.seek(heading.offset)
      heading = @file.gets
      unless heading && heading.lstrip.starts_with? '#'
        # Skip underline
        @file.gets
      end
    end
  end
end
