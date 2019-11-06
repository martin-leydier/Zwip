require "mime"

module FileSystem
  extend self

  class FileSystemEntry
    getter real_path : String
    getter basename : String
    getter file_info : File::Info
    getter mime : String
    getter icon : String
    getter size : UInt64
    getter path : String

    def initialize(@real_path : String, @file_info : File::Info)
      @mime = MIME.from_filename(@real_path, "text/plain")
      @icon = get_icon
      @size = @file_info.size
      @basename = File.basename(real_path)
      @path = @real_path.lchop(Settings.root)
      @path = File::SEPARATOR + @path if @path.empty? || @path[0] != File::SEPARATOR
    end

    def modification_time
      @file_info.modification_time
    end

    def type
      @file_info.type
    end

    def directory?
      false
    end

    def to_s(io)
      io << real_path << ", " << size << ", " << icon
    end

    private def get_icon
      case
      when @file_info.directory?
        return "folder"
      when @mime.nil?
        return "file"
      when @mime.starts_with? "video"
        return "file video"
      when @mime.starts_with? "audio"
        return "file audio"
      when @mime.starts_with? "image"
        return "file image"
      when @mime.starts_with? "text"
        return "file alternate"
      else
        return "file"
      end
    end
  end

  class FileSystemDirectory < FileSystemEntry
    getter content : Array(FileSystemEntry)

    def initialize(@real_path : String, @file_info : File::Info)
      super
      @content = [] of FileSystemEntry
    end

    def add_entry(entry : FileSystemEntry)
      @content << entry
      @size += entry.size
    end

    def to_s(io)
      super
      @content.each do |entry|
        io << "\n" << entry
      end
    end

    def each
      @content.each do |e|
        yield e
      end
    end

    def type
      File::Type.Directory
    end

    def directory?
      true
    end
  end

  def index(path, depth = 1, file_info = nil)
    file_info = File.info(path) if file_info.nil?
    if file_info.directory?
      this = FileSystemDirectory.new(path, file_info)
      if depth != 0
        sorted_indexable(Dir.children(path), path).each do |child, child_info|
          indexed = index(child, depth - 1, child_info)
          this.add_entry indexed
        end
      end
    else
      this = FileSystemEntry.new(path, file_info)
    end
    return this
  end

  private def sorted_indexable(entries, base_path)
    visible = [] of Tuple(String, File::Info)
    entries.each do |e|
      next if e[0] == '.'
      full_path = File.join(base_path, e)
      next unless File.readable? full_path
      info = File.info full_path
      visible << {full_path, info}
    end
    return visible.sort { |a, b| dir_sort(a[0], b[0], a[1], b[1]) }
  end

  # A comparison function to sort a directory content
  # It does a case insensitive, directory first comparison
  #
  # For example:
  #
  # ```
  # Hello(dir) < A(file)
  # hello(dir) < Hello(file)
  # Hello(file) == hello(file)
  # ```
  #
  # if a file_info_x argument is nil, then its corresponding path_x must be an absolute path or relative path,
  # it cannot be a simple filename
  private def dir_sort(path_1, path_2, file_info_1 = nil, file_info_2 = nil)
    path_1 = path_1.downcase
    path_2 = path_2.downcase

    is_dir_1 = if file_info_1.nil?
                 File.directory? path_1
               else
                 file_info_1.directory?
               end

    is_dir_2 = if file_info_2.nil?
                 File.directory? path_2
               else
                 file_info_2.directory?
               end

    if is_dir_1
      if is_dir_2
        return path_1 <=> path_2
      else
        return -1
      end
    else
      if is_dir_2
        return 1
      else
        return path_1 <=> path_2
      end
    end
  end
end
