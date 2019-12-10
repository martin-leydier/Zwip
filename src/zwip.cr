require "kemal"
require "kilt/slang"
require "html"

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
  files = env.params.query["files"].split(',', remove_empty: true)
  indexed = index_paths(files, -1)
  log({action: "Download started", files: indexed.map { |e| e.path }}, env)
  if indexed.size == 1 && !indexed[0].directory?
    send_file env, indexed[0].real_path, filename: indexed[0].basename, disposition: "attachment"
  elsif indexed.size > 0
    args = ["-", "-r", "-0", "--"]
    indexed.each do |i|
      args << ".#{i.path}"
    end
    env.response.content_type = "application/zip"
    env.response.headers["content-disposition"] = "attachment; filename=\"download.zip\""
    Process.run(command: Settings.zip_path, args: args, clear_env: true, shell: false, input: Process::Redirect::Close, output: env.response, error: Process::Redirect::Close, chdir: Settings.root)
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
    send_file env, files.real_path
  end
end

FileStorage.files.each do |file|
  get(file.path) do |env|
    FileStorage.serve(file, env)
  end
end

Kemal.run
