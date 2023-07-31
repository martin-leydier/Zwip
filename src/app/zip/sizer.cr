require "../filesystem.cr"

class ZipSizer
  getter size : UInt64 = 0

  @added_files = Set(String).new

  def initialize
    @size += sizeof(ZipStructs::Zip64EndOfCentralDirectoryRecord)
    @size += sizeof(ZipStructs::Zip64EndOfCentralDirectoryLocator)
    @size += sizeof(ZipStructs::EndOfCentralDirectoryRecord)
  end

  def add(file : FileSystem::FileSystemEntry) : Nil
    file_path = file.path[1..]
    new_file = @added_files.add? file_path
    return unless new_file

    @size += sizeof(ZipStructs::LocalFileHeader)
    @size += file_path.encode("UTF-8").size
    @size += sizeof(ZipStructs::Zip64ExtraField)
    @size += file.size
    @size += sizeof(ZipStructs::DataDescriptor64)
    @size += sizeof(ZipStructs::CentralDirectoryHeader)
    @size += file_path.encode("UTF-8").size
    @size += sizeof(ZipStructs::Zip64ExtraFieldCDR)
  end
end
