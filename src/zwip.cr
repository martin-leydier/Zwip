require "baked_file_system"
require "html"

require "./app/helper.cr"
require "./app/filesystem.cr"

class FileStorage
  START_TIME = Time.local
  BakedFileSystem.load("../public", __DIR__)

  def self.serve(file, ctx)
    req = ctx.request
    resp = ctx.response
    resp.status_code = 200
    resp.content_type = MIME.from_filename?(file.path) || "text/html"
    last_modified = START_TIME
    add_cache_headers(resp.headers, START_TIME)
    if cache_request?(ctx, START_TIME)
      resp.status_code = 304
      return
    end
    if req.headers["Accept-Encoding"]? =~ /gzip/
      resp.headers["Content-Encoding"] = "gzip"
      resp.content_length = file.compressed_size
      file.write_to_io(resp, compressed: true)
    else
      resp.content_length = file.size
      file.write_to_io(resp, compressed: false)
    end
  end

  # Function from crystal's HTTP::StaticFileHandler
  private def self.add_cache_headers(response_headers : HTTP::Headers, last_modified : Time) : Nil
    response_headers["Etag"] = etag(last_modified)
    response_headers["Last-Modified"] = HTTP.format_time(last_modified)
    response_headers["Cache-Control"] = "max-age=31536000"
  end

  # Function from crystal's HTTP::StaticFileHandler
  private def self.cache_request?(context : HTTP::Server::Context, last_modified : Time) : Bool
    # According to RFC 7232:
    # A recipient must ignore If-Modified-Since if the request contains an If-None-Match header field
    if if_none_match = context.request.if_none_match
      match = {"*", context.response.headers["Etag"]}
      if_none_match.any? { |etag| match.includes?(etag) }
    elsif if_modified_since = context.request.headers["If-Modified-Since"]?
      header_time = HTTP.parse_time(if_modified_since)
      # File mtime probably has a higher resolution than the header value.
      # An exact comparison might be slightly off, so we add 1s padding.
      # Static files should generally not be modified in subsecond intervals, so this is perfectly safe.
      # This might be replaced by a more sophisticated time comparison when it becomes available.
      !!(header_time && last_modified <= header_time + 1.second)
    else
      false
    end
  end

  # Function from crystal's HTTP::StaticFileHandler
  private def self.etag(modification_time)
    %{W/"#{modification_time.to_unix}"}
  end
end

before_get do |env|
  request_path = full_path env
  unless valid_path? request_path
    env.redirect "/"
    halt env, status_code: 307
  end
end

get "/.download" do |env|
  view("site/download", env)
end

get "/.zip" do |env|
  files = env.params.query["files"].split(',', remove_empty: true)
  indexed = index_paths(files, -1)
  if indexed.size == 1 && !indexed[0].directory?
    send_file env, indexed[0].real_path, filename: indexed[0].basename, disposition: "attachment"
  elsif indexed.size > 0
    args = ["-", "-r", "-0", "--"]
    indexed.each do |i|
      args << ".#{i.path}"
    end
    env.response.content_type = "application/zip"
    env.response.headers["content-disposition"] = "attachment; filename=\"download.zip\""
    Process.run(command: ZIP_PATH, args: args, clear_env: true, shell: false, input: Process::Redirect::Close, output: env.response, error: Process::Redirect::Close, chdir: ENV["ROOT"])
  else
    env.redirect "/.download"
  end
  env
end

get "/.list" do |env|
  cart = get_cart(env)
  view("site/list", env)
end

get "/" do |env|
  files = FileSystem.index(ENV["ROOT"]).as(FileSystem::FileSystemDirectory)
  view("site/index", env)
end

get "/*" do |env|
  halt env if env.response.status_code == 307
  path = env.request.path
  files = FileSystem.index(full_path env)
  if files.is_a? FileSystem::FileSystemDirectory
    view("site/index", env)
  else
    send_file env, files.real_path
  end
end

FileStorage.files.each do |file|
  get(file.path) do |env|
    FileStorage.serve(file, env)
  end
end
