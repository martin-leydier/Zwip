require "kemal"
require "kilt/slang"
require "html"
require "cr_zip_tricks"

require "./app/*"
require "./macros/*"

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
  env.response.headers.add("Accept-Ranges", "none")
  files = env.params.query.fetch_all("files")
  indexed = nil

  zip_size = ZipTricks::Sizer.size do |s|
    indexed = index_paths(files, -1, s)
  end

  if indexed.nil?
    next env.redirect "/.download"
  end

  log({action: "Download started", files: indexed.map { |e| e.path }, estimated_size: zip_size}, env)

  if indexed.size == 1 && !indexed[0].directory?
    send_file env, indexed[0].real_path, filename: indexed[0].basename, disposition: "attachment"
  elsif indexed.size > 0
    env.response.content_type = "application/zip"
    env.response.headers["content-disposition"] = "attachment; filename=\"download.zip\""
    env.response.headers["content-length"] = zip_size.to_s
    ZipTricks::Streamer.archive(env.response) do |s|
      indexed.each do |e|
        e.each_file do |f|
          s.add_stored(f.path) do |sink|
            File.open(f.real_path, "rb") do |f|
              IO.copy(f, sink)
            end
          end
        end
      end
    end
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
  files = FileSystem.index(Settings.root).as(FileSystem::FileSystemDirectory)
  view("site/index", env)
end

get "/*" do |env|
  halt env if env.response.status_code == 307
  path = env.request.path
  files = FileSystem.index(full_path env)
  if files.is_a? FileSystem::FileSystemDirectory
    view("site/index", env)
  else
    send_file env, files.real_path, filename: files.basename, disposition: "attachment"
  end
end

FileStorage.files.each do |file|
  get(file.path) do |env|
    FileStorage.serve(file, env)
  end
end

Kemal.run
