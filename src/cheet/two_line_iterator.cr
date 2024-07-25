class Cheet::TwoLineIterator
  include Iterator({String, UInt64, String?, UInt64?})
  include IteratorWrapper

  @iterator : Iterator(String)

  def initialize(@io : IO)
    @iterator = io.each_line
    @line = ""
    @line_offset = 0u64
    @next_line = ""
    @next_line_offset = 0u64
    @at_start = true
  end

  def next
    if @at_start
      @next_line_offset = @io.pos.to_u64
      @next_line = wrapped_next
      @at_start = false
    end
    @line = @next_line
    @line_offset = @next_line_offset
    return Iterator.stop if @line == Iterator.stop
    @next_line_offset = @io.pos.to_u64
    @next_line = wrapped_next
    unless @next_line == Iterator.stop
      {@line, @line_offset, @next_line, @next_line_offset}
    else
      {@line, @line_offset, nil, nil}
    end
  end
end
