def valid_path?(path : String)
  expanded_path = File.expand_path(path)
  return false unless expanded_path.starts_with?(ENV["ROOT"])
  request_path = expanded_path.lchop(ENV["ROOT"]).split('/', remove_empty: true)
  return true if request_path.size == 1 && ({".list", ".download", ".zip"}.any? request_path[0])
  return false if request_path.any? { |e| e[0] == '.' }
  return true if FileStorage.files.map(&.path).includes?(expanded_path.lchop(ENV["ROOT"]))
  return File.exists? expanded_path
end

def full_path(path : String)
  File.join(ENV["ROOT"], path)
end

def full_path(env : HTTP::Server::Context)
  File.join(ENV["ROOT"], URI.unescape(env.request.path))
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

def get_cart(env) : Array(FileSystem::FileSystemEntry)
  if env.request.cookies["cart"]?
    begin
      cart_paths = Array(String).from_json(env.request.cookies["cart"].value)
      return index_paths(cart_paths)
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
    cart.join(",", io) do |item, join_io|
      URI.escape(item.path, join_io)
    end
    cart.each do |item|
    end
  end
end
