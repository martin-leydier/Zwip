require "kemal"
require "kilt/slang"

require "./src/macros/*"
require "./src/zwip.cr"
require "./src/app/json_log_handler.cr"

File.read_lines(".env").each do |line|
  key, value = line.strip.split "="
  ENV[key] ||= value
end

ENV["ROOT"] = File.expand_path(ENV["ROOT"])

Kemal.config.powered_by_header = false

Kemal.config.logger = JsonLogHandler.new
