require "./zip_structs.cr"

require "../io_helpers/crc_wrapper.cr"
require "../filesystem.cr"

class ZipWriteIO
  @entries_count : UInt64 = 0
  @added_files = Set(String).new

  def initialize(@io : IO)
    # minimum size for a 1-file archive
    @central_directory_IO = IO::Memory.new(sizeof(ZipStructs::CentralDirectoryHeader) + sizeof(ZipStructs::Zip64EndOfCentralDirectoryRecord) + sizeof(ZipStructs::Zip64EndOfCentralDirectoryLocator) + sizeof(ZipStructs::EndOfCentralDirectoryRecord))
  end

  private def write_struct(s, io = @io)
    io.write Slice.new(pointerof(s), 1).to_unsafe_bytes
  end

  # https://learn.microsoft.com/en-us/windows/win32/api/winbase/nf-winbase-dosdatetimetofiletime
  private def to_dos_time(time : Time) : UInt16
    (time.second.to_u16 // 2) | (time.minute.to_u16 << 5) | (time.hour.to_u16 << 10)
  end

  private def to_dos_date(date : Time) : UInt16
    date.day.to_u16 | (date.month.to_u16 << 5) | ((date.year - 1980).to_u16 << 9)
  end

  def add(file : FileSystem::FileSystemEntry) : Nil
    lfh_offset = @io.tell
    file_path = file.path[1..]
    new_file = @added_files.add? file_path
    return unless new_file

    write_struct ZipStructs::LocalFileHeader.new(
      signature: 0x04034b50,
      # So the zip spec doesn't seem clear about this: the UTF-8 in filename spec is newer than the ZIP spec
      # but the version needed doesn't say what it should be for it to support UTF-8
      version_extract: 45,
      # Use data descriptor, use UTF-8
      general_flag: (1 << 3) | (1 << 11),
      compression_method: 0,
      last_modify_time: to_dos_time(file.modification_time),
      last_modify_date: to_dos_date(file.modification_time),
      crc32: 0,
      compressed_size: UInt32::MAX,
      uncompressed_size: UInt32::MAX,
      file_name_length: file_path.bytesize,
      extra_field_length: sizeof(ZipStructs::Zip64ExtraField),
    )

    @io.write file_path.encode("UTF-8")
    write_struct ZipStructs::Zip64ExtraField.new(
      id: 1,
      size: 16,
      uncompressed_size: file.size,
      compressed_size: file.size
    )

    crc_wrapper = CRCWrapper.new @io
    File.open(file.real_path, "r") do |file|
      IO.copy(file, crc_wrapper)
    end
    crc32 : UInt32 = crc_wrapper.crc32

    write_struct ZipStructs::DataDescriptor64.new(
      signature: 0x08074b50,
      crc32: crc32,
      compressed_size: file.size,
      uncompressed_size: file.size
    )

    write_struct ZipStructs::CentralDirectoryHeader.new(
      signature: 0x02014b50,
      version_made: (45 << 8) | 3,
      version_extract: 45,
      # Use data descriptor, use UTF-8
      general_flag: (1 << 3) | (1 << 11),
      compression_method: 0,
      last_modify_time: to_dos_time(file.modification_time),
      last_modify_date: to_dos_date(file.modification_time),
      crc32: crc32,
      compressed_size: UInt32::MAX,
      uncompressed_size: UInt32::MAX,
      file_name_length: file_path.bytesize,
      extra_field_length: sizeof(ZipStructs::Zip64ExtraFieldCDR),
      file_comment_length: 0,
      disk_number: 0,
      internal_file_attributes: 0,
      # regular file, 644 perms (no execute)
      external_file_attributes: 0x81a40000,
      file_offset: UInt32::MAX,
    ), @central_directory_IO

    @central_directory_IO.write file_path.encode("UTF-8")
    write_struct ZipStructs::Zip64ExtraFieldCDR.new(
      id: 1,
      size: 24,
      uncompressed_size: file.size,
      compressed_size: file.size,
      relative_header_offset: lfh_offset,
    ), @central_directory_IO
    @entries_count += 1
  end

  def write_end_of_archive
    @central_directory_IO.rewind
    cd_offset = @io.tell
    IO.copy @central_directory_IO, @io
    zip64_eocdr_offset = @io.tell
    write_struct ZipStructs::Zip64EndOfCentralDirectoryRecord.new(
      signature: 0x06064b50,
      size: sizeof(ZipStructs::Zip64EndOfCentralDirectoryRecord) - offsetof(ZipStructs::Zip64EndOfCentralDirectoryRecord, @version_made),
      version_made: (45 << 8) | 3,
      version_extract: 45,
      disk_number: 0,
      start_of_central_directory_disk_number: 0,
      entries_count_on_disk: @entries_count,
      entries_count_total: @entries_count,
      central_directory_size: @central_directory_IO.size,
      central_directory_start_offset: cd_offset
    )
    write_struct ZipStructs::Zip64EndOfCentralDirectoryLocator.new(
      signature: 0x07064b50,
      zip64_eocd_start_disk_number: 0,
      zip64_eocdr_relative_offset: zip64_eocdr_offset,
      disk_count: 1
    )
    write_struct ZipStructs::EndOfCentralDirectoryRecord.new(
      signature: 0x06054b50,
      eocd_start_disk_number: 0,
      central_directory_entries_count_on_disk: UInt16::MAX,
      central_directory_entries_total_count: UInt16::MAX,
      central_directory_size: @central_directory_IO.size,
      central_directory_start_offset: UInt32::MAX,
      comment_length: 0
    )
  end
end
