require "./heading"

class Cheet::Index
  getter headings = [] of Heading

  def to_s(io : IO)
    io << @headings
  end

  def next_at_level(start : Int32, level = level_of(start)) : Heading?
    headings.each
        .skip(start + 1)
        .select { |heading| heading.level == level }
        .first?
  end

  def next_above_or_at_level(start : Int32, level = level_of(start)) : Heading?
    headings.each
        .skip(start + 1)
        .select { |heading| heading.level <= level }
        .first?
  end

  private def level_of(index)
    @headings[index]?.try &.level
  end
end
