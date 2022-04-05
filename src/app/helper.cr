def info_path(path)
  path = path.chomp "/"
  return "/" if path.empty?

  return path
end

def valid_path?(path : String)
  expanded_path = File.expand_path path
  return {false, nil} unless expanded_path.starts_with?(Settings.root) # path cannot be outside of root

  request_path = expanded_path.lchop(Settings.root).split('/', remove_empty: true)
  return {true, nil} if request_path.size == 1 && ({".list", ".download", ".zip"}.any? request_path[0]) # path can be a reserved path

  return {false, nil} if request_path.any? { |e| e[0] == '.' } # path cannot be a hidden file/folder

  return {true, nil} unless FileStorage.get?(expanded_path.lchop(Settings.root)).nil? # path can be a public resource

  begin
    real_path = File.real_path expanded_path
  rescue e : File::NotFoundError | File::Error # File::Error is raised when attempting to treat a file as a directory
    return {false, nil}
  end

  return {false, nil} if expanded_path.chomp("/") != real_path.chomp("/") # path cannot contain symlinks

  info = File.info?(info_path(expanded_path), false)
  return {true, info} if info && (info.directory? || info.file?) # path should be either a file or a dir

  return {false, nil}
end

def log(message, env : HTTP::Server::Context? = nil)
  Kemal.config.logger.as(JsonLogHandler).write_msg message, env
end

def full_path(path : String)
  File.join(Settings.root, path)
end

def full_path(env : HTTP::Server::Context)
  File.join(Settings.root, URI.decode_www_form(env.request.path, plus_to_space: false))
end

def index_paths(paths : Array(String), depth = 0, zip_sizer : ZipTricks::Sizer? = nil) : Array(FileSystem::FileSystemEntry)
  indexed = [] of FileSystem::FileSystemEntry
  p_set = Set(String).new
  paths.each do |path|
    real_path = File.expand_path(full_path(path))
    valid, info = valid_path? real_path
    next if !valid || info.nil?
    next if info.directory? && p_set.any? { |e| real_path.starts_with? e }
    p_set.add real_path
    indexed << FileSystem.index(real_path, depth, nil, zip_sizer)
  end
  return indexed
end

def cart_empty?(env) : Bool
  return false unless env.request.cookies["cart"]?
  begin
    cart_paths = Array(String).from_json(env.request.cookies["cart"].value)
    return cart_paths.empty?
  rescue e : JSON::ParseException
    return false
  end
end

def get_cart(env) : Array(FileSystem::FileSystemEntry)
  if env.request.cookies["cart"]?
    begin
      cart_paths = Array(String).from_json(URI.decode_www_form(env.request.cookies["cart"].value))
      return index_paths(cart_paths, -1)
    rescue e : JSON::ParseException
      return [] of FileSystem::FileSystemEntry
    end
  end
  return [] of FileSystem::FileSystemEntry
end

def build_dl(env)
  cart = get_cart(env)
  String.build do |io|
    io << "/.zip?files="
    cart.join(io, "&files=") do |item, join_io|
      URI.encode_www_form(item.path, join_io, space_to_plus: false)
    end
    cart.each do |item|
    end
  end
end

def get_prev_folder(path)
  path_split = path.split("/", remove_empty: true)
  return "/" if path_split.size < 2

  return URI.decode_www_form(path_split[-2], plus_to_space: false)
end

class SkippingResponse < IO
  def read(slice : Bytes)
    raise IO::Error.new "Unsupported operation"
  end

  def write(slice : Bytes) : Nil
    return unless @selected.includes? @pos

    sub_slice = slice[0, (@selected.end - @pos - (@selected.excludes_end? ? 1 : 0)).clamp(nil, slice.size - 1)]?
    return if sub_slice.nil?

    @pos += sub_slice.size
    @response.write(sub_slice)
    @response.close unless @selected.includes? @pos
  end

  def initialize(@response : HTTP::Server::Response, @selected : Range(UInt64, UInt64))
    @pos : UInt64 = 0
    super()
  end
end
