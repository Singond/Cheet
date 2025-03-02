struct Cheet::Heading
  getter value : String
  getter level : UInt8
  getter offset : UInt64
  # Returns the numeric index into the associated Index object.
  getter index : Int32?

  def initialize(@value, @level, @offset, @index = nil)
  end

  def initialize(heading : Heading, index)
    initialize(heading.value, heading.level, heading.offset, index)
  end

  def to_s(io : IO)
    io << "#" * @level << " #{@value} (#{@offset})"
  end

  def inspect(io : IO)
    to_s io
  end

  def matches?(*args)
    @value.matches? *args
  end

  def matches?(topic : Topic, *, case_insensitive = true, whole_word = true)
    heading = @value
    if case_insensitive
      heading = heading.downcase
      topic = topic.downcase
    end
    if whole_word
      heading.split.any? &.== topic
    else
      heading.includes? topic
    end
  end
end
