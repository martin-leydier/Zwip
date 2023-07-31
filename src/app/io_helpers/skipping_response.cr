class SkippingResponse < IO
  @pos : UInt64 = 0

  def initialize(@response : HTTP::Server::Response, @selected : Range(UInt64, UInt64))
    super()
  end

  def read(slice : Bytes)
    raise IO::Error.new "Unsupported operation"
  end

  def write(slice : Bytes) : Nil
    return unless @selected.includes? @pos

    sub_slice = slice[0, (@selected.end - @pos - (@selected.excludes_end? ? 1 : 0)).clamp(nil, slice.size)]?
    return if sub_slice.nil?

    @pos += sub_slice.size
    @response.write(sub_slice)
    @response.close unless @selected.includes? @pos
  end

  def tell : UInt64
    @pos
  end
end
