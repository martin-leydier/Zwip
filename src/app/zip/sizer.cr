require "../filesystem.cr"

class ZipSizer
  getter size : UInt64 = 0

  def initialize
    @size += sizeof(ZipStructs::Zip64EndOfCentralDirectoryRecord)
    @size += sizeof(ZipStructs::Zip64EndOfCentralDirectoryLocator)
    @size += sizeof(ZipStructs::EndOfCentralDirectoryRecord)
  end

  def add(file : FileSystem::FileSystemEntry) : Nil
    file_path = file.path[1..]
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
