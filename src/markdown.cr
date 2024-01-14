require "./core"
require "./document"

module Cheet::Markdown

  class MarkdownDocument < Document

    def initialize(name)
      super(name)
    end

    def do_index : Index
      offset = 0u64
      prev_line = ""
      prev_line_offset = 0u64
      idx = Index.new

      @file.seek(0)
      @file.each_line do |line|
        if line.starts_with?('#')
          lvl = 0u8
          chars = line.each_char
          while chars.next == '#'
            lvl += 1
          end
          value = line[lvl..].strip
          idx.headings << Heading.new(value, lvl, offset)
        end
        prev_line = line
        prev_line_offset = offset
        offset = @file.pos.to_u64
      end
      idx
    end

    def skip_to_content(heading : Heading)
      @file.seek(heading.offset)
      @file.gets
    end
  end
end
