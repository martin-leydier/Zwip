require "yaml"

require "./json_log_handler.cr"

class IOConverter
  def self.from_json(parser : JSON::PullParser)
    filename = parser.read_string
    return STDOUT if filename.empty?
    File.open filename, "a"
  end
end

class Config
  JSON.mapping(
    root: {type: String, default: "/var/www"},
    port: {type: Int32, default: 3000},
    zip_path: {type: String, default: ""},
    log_path: {type: IO, default: STDOUT, converter: IOConverter},
    trust_headers_ip?: {type: Bool, default: false},
    log_headers: {type: Array(String), default: [] of String},
    kemal_env: {type: String, default: "production"}
  )

  def self.load : Config
    settings = File.open("config.json") { |f| Config.from_json f }
    settings.port = ENV.fetch("PORT", settings.port.to_s).to_i
    settings.root = ENV.fetch("ROOT", settings.root)
    settings.root = File.expand_path settings.root
    if settings.zip_path.empty? || !File.exists?(settings.zip_path)
      settings.zip_path = ENV["PATH"].split ':' do |path|
        zip_path = File.join(path, "zip")
        if File.exists?(zip_path)
          break zip_path
        end
      end || ""
    end
    abort "Could not find zip(1) in config or in PATH" if settings.zip_path.empty?
    settings
  end
end

Settings = Config.load
Kemal.config.powered_by_header = false
Kemal.config.logger = JsonLogHandler.new Settings.log_path
Kemal.config.shutdown_message = false
Kemal.config.port = Settings.port
Kemal.config.env = Settings.kemal_env
