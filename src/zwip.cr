require "./app/helper.cr"
require "./app/filesystem.cr"

before_get do |env|
    request_path = full_path env
    unless valid_path? request_path
        env.redirect "/"
        halt env, status_code: 307
    end
end


get "/.download" do |env|
    view("site/download")
end

get "/.zip" do |env|
    files = env.params.query["files"].split(",", remove_empty: true)
    indexed = index_paths(files, -1)
    if indexed.size == 1 && !indexed[0].directory?
        send_file env, indexed[0].real_path, filename: indexed[0].basename
    else
        args = ["-", "-r", "-0", "--"]
        indexed.each do |i|
            args << ".#{i.path}"
        end
        env.response.content_type = "application/zip"
        env.response.headers["content-disposition"] = "attachment; filename=\"download.zip\""
        puts Process.run(command: "zip", args: args , clear_env: true, shell: false, input: Process::Redirect::Close, output: env.response, error: Process::Redirect::Close, chdir: ENV["ROOT"])
    end
    env
end

get "/.list" do |env|
    cart = get_cart(env)

    view("site/list")
end

get "/" do |env|
    files = FileSystem.index(ENV["ROOT"]).as(FileSystem::FileSystemDirectory)
    view("site/index")
end

get "/*" do |env|
    halt env if env.response.status_code == 307
    path = env.request.path
    files = FileSystem.index(full_path env)
    if files.is_a? FileSystem::FileSystemDirectory
        view("site/index")
    else
        send_file env, files.real_path
    end
end
