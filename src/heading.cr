class Cheet::Heading
  getter value : String
  getter level : UInt8
  getter offset : UInt64

  def initialize(@value, @level, @offset)
  end

  def to_s(io : IO)
    io << "#" * @level << " #{@value} (#{@offset})"
  end

  def inspect(io : IO)
    to_s io
  end
end
