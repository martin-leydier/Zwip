def info_path(path)
  path = path.chomp "/"
  return "/" if path.empty?
  return path
end

def valid_path?(path : String)
  expanded_path = File.expand_path path
  return false unless expanded_path.starts_with?(Settings.root) # path cannot be outside of root
  request_path = expanded_path.lchop(Settings.root).split('/', remove_empty: true)
  return true if request_path.size == 1 && ({".list", ".download", ".zip"}.any? request_path[0]) # path is can be a reserved path
  return false if request_path.any? { |e| e[0] == '.' }                                          # path is cannot be a hidden file/folder
  return true unless FileStorage.get?(expanded_path.lchop(Settings.root)).nil?                   # path is can be a public resource
  begin
    real_path = File.real_path expanded_path
  rescue e : File::NotFoundError
    return false
  end
  return false if expanded_path.chomp("/") != real_path.chomp("/") # path cannot contain symlinks
  info = File.info?(info_path(expanded_path), false)
  return info && (info.directory? || info.file?) # path should be either a file or a dir
end

def log(message, env : HTTP::Server::Context? = nil)
  Kemal.config.logger.as(JsonLogHandler).write_json message.to_json, env
end

def full_path(path : String)
  File.join(Settings.root, path)
end

def full_path(env : HTTP::Server::Context)
  File.join(Settings.root, URI.decode_www_form(env.request.path, plus_to_space: false))
end

def index_paths(paths : Array(String), depth = 0) : Array(FileSystem::FileSystemEntry)
  indexed = [] of FileSystem::FileSystemEntry
  paths.each do |path|
    full_path = full_path path
    next unless valid_path? full_path
    indexed << FileSystem.index(full_path, depth)
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
      cart_paths = Array(String).from_json(env.request.cookies["cart"].value)
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
