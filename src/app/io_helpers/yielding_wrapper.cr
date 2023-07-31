class YieldingWrapper < IO
  @pos : UInt64 = 0

  def initialize(@io : IO, @slice_size = 4096)
    super()
  end

  def read(slice : Bytes)
    raise IO::Error.new "Unsupported operation"
  end

  def write(slice : Bytes) : Nil
    offset = 0
    while offset < slice.size
      @io.write(slice[offset, Math.min(@slice_size, slice.size - offset)])
      offset += @slice_size
      Fiber.yield
    end
    @pos += slice.size
  end

  def pos : UInt64
    @pos
  end
end
