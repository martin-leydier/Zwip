require "digest/crc32"

class CRCWrapper < IO
  getter crc32

  def initialize(@io : IO)
    @crc32 = Digest::CRC32.initial
  end

  def read(slice : Bytes)
    raise IO::Error.new "Unsupported operation"
  end

  def write(slice : Bytes) : Nil
    return if slice.empty?
    @crc32 = Digest::CRC32.update(slice, @crc32)
    @io.write slice
  end
end
