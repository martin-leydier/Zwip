require "kilt/slang"
require "kemal"
require "html"
require "cr_zip_tricks"

require "./app/*"
require "./macros/*"

before_get do |env|
  request_path = full_path env
  unless valid_path?(request_path)[0]
    env.redirect "/"
    halt env, status_code: 307
  end
end

get "/#{RESERVED_PATHS[:health]}" do |env|
  halt env
end

get "/#{RESERVED_PATHS[:download]}" do |env|
  view "site/download"
end

get "/#{RESERVED_PATHS[:zip]}" do |env|
  env.response.headers.add("Accept-Ranges", "none")
  files = env.params.query.fetch_all("files")
  indexed = nil

  zip_size = ZipTricks::Sizer.size do |s|
    indexed = index_paths(files, -1, s)
  end

  if indexed.nil?
    next env.redirect "/.download"
  end

  if indexed.size == 1 && !indexed[0].directory?
    log({action: "Download started", files: indexed.map { |e| e.path }, estimated_size: indexed[0].size}, env)
    send_file env, indexed[0].real_path, filename: indexed[0].basename, disposition: "attachment"
  elsif indexed.size > 0
    log({action: "Download started", files: indexed.map { |e| e.path }, estimated_size: zip_size}, env)
    env.response.content_type = "application/zip"
    env.response.headers["content-disposition"] = "attachment; filename=\"download.zip\""
    env.response.headers["content-length"] = zip_size.to_s
    ZipTricks::Streamer.archive(env.response) do |s|
      indexed.each do |e|
        e.each_file do |f|
          s.add_stored(f.path) do |sink|
            File.open(f.real_path, "rb") do |f|
              buffer = uninitialized UInt8[4096]
              count = 0_i64
              while (len = f.read(buffer.to_slice).to_i32) > 0
                sink.write buffer.to_slice[0, len]
                count &+= len
                Fiber.yield if count % 40960 == 0 # give other transfers a chance
              end
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
  view "site/list"
end

get "/" do |env|
  files = FileSystem.index(Settings.root).as(FileSystem::FileSystemDirectory)
  view "site/index"
end

get "/*" do |env|
  halt env if env.response.status_code == 307
  path = env.request.path
  files = FileSystem.index(full_path env)
  if files.is_a? FileSystem::FileSystemDirectory
    view "site/index"
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
