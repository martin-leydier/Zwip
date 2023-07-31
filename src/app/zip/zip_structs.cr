lib ZipStructs
  @[Packed]
  struct Zip64ExtraField
    id : UInt16
    size : UInt16
    uncompressed_size : UInt64
    compressed_size : UInt64
  end

  @[Packed]
  struct Zip64ExtraFieldCDR
    include Zip64ExtraField
    relative_header_offset : UInt64
  end

  @[Packed]
  struct DataDescriptor64
    signature : UInt32
    crc32 : UInt32
    compressed_size : UInt64
    uncompressed_size : UInt64
  end

  @[Packed]
  struct LocalFileHeader
    signature : UInt32
    version_extract : UInt16
    general_flag : UInt16
    compression_method : UInt16
    last_modify_time : UInt16
    last_modify_date : UInt16
    crc32 : UInt32
    compressed_size : UInt32
    uncompressed_size : UInt32
    file_name_length : UInt16
    extra_field_length : UInt16
  end

  @[Packed]
  struct CentralDirectoryHeader
    signature : UInt32
    version_made : UInt16
    version_extract : UInt16
    general_flag : UInt16
    compression_method : UInt16
    last_modify_time : UInt16
    last_modify_date : UInt16
    crc32 : UInt32
    compressed_size : UInt32
    uncompressed_size : UInt32
    file_name_length : UInt16
    extra_field_length : UInt16
    file_comment_length : UInt16
    disk_number : UInt16
    internal_file_attributes : UInt16
    external_file_attributes : UInt32
    file_offset : UInt32
  end

  @[Packed]
  struct Zip64EndOfCentralDirectoryRecord
    signature : UInt32
    size : UInt64
    version_made : UInt16
    version_extract : UInt16
    disk_number : UInt32
    start_of_central_directory_disk_number : UInt32
    entries_count_on_disk : UInt64
    entries_count_total : UInt64
    central_directory_size : UInt64
    central_directory_start_offset : UInt64
  end

  @[Packed]
  struct Zip64EndOfCentralDirectoryLocator
    signature : UInt32
    zip64_eocd_start_disk_number : UInt32
    zip64_eocdr_relative_offset : UInt64
    disk_count : UInt32
  end

  @[Packed]
  struct EndOfCentralDirectoryRecord
    signature : UInt32
    disk_number : UInt16
    eocd_start_disk_number : UInt16
    central_directory_entries_count_on_disk : UInt16
    central_directory_entries_total_count : UInt16
    central_directory_size : UInt32
    central_directory_start_offset : UInt32
    comment_length : UInt16
  end
end
