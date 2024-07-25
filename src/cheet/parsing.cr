require "./heading"

module Cheet

  def self.atx_heading(line, offset = 0u64) : Heading?
    if line.starts_with?('#')
      lvl = 0u8
      chars = line.each_char
      while chars.next == '#'
        lvl += 1
      end
      value = line[lvl..].strip
      Heading.new(value, lvl, offset)
    end
  end

  def self.setext_heading(lines, offset = 0u64) : Heading?
    next_line = lines.last
    return nil unless next_line
    first_char = next_line[0]?
    heading_level = case first_char
      when '=' then 1u8
      when '-' then 2u8
      when '~' then 3u8
      when '^' then 4u8
      when '+' then 5u8
      else nil
    end
    if heading_level && consists_only_of?(next_line, first_char)
      Heading.new lines[0...-1].accumulate.join(" "), heading_level, offset
    end
  end

  def self.consists_only_of?(string, char)
    char_iter = string.each_char
    # Consume matching characters
    while (last_char = char_iter.next) == char
    end
    # If the character iterator would return no more characters,
    # the string contains only *char*s.
    last_char == Iterator.stop
  end
end
