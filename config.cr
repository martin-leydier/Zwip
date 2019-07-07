require "kemal"
require "kilt/slang"

require "./src/macros/*"
require "./src/zwip.cr"
require "./src/app/json_log_handler.cr"

if File.exists? ".env"
  File.read_lines(".env").each do |line|
    key, value = line.strip.split "="
    ENV[key] ||= value
  end
end

ENV["ROOT"] = File.expand_path(ENV["ROOT"])

ZIP_PATH = ENV["PATH"].split ':' do |path|
  zip_path = File.join(path, "zip")
  if File.exists?(zip_path)
    break zip_path
  end
end || ""

abort "Could not find zip(1) in PATH" if ZIP_PATH == ""

Kemal.config.powered_by_header = false

Kemal.config.logger = JsonLogHandler.new
