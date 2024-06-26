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
  include JSON::Serializable
  include JSON::Serializable::Strict

  property root : String = "/var/www"
  property port : UInt16 = 3000

  @[JSON::Field(key: "log_path", converter: IOConverter)]
  property log : IO::FileDescriptor = STDOUT

  property trust_headers_ip : Bool = false
  property log_headers : Array(String) = [] of String
  property kemal_env : String = "production"

  def self.load : Config
    settings_path = ""

    OptionParser.parse do |parser|
      parser.banner = "Usage: #{PROGRAM_NAME} [options]"
      parser.on "-h", "--help", "Show this help" do
        puts parser
        exit
      end
      parser.on "-c PATH", "--config=PATH", "Set config file path" do |path|
        settings_path = path
      end
      parser.on "-h PORT", "--health=PORT", "Check service health at given port" do |port_str|
        begin
          port = port_str.to_u16
        rescue ArgumentError
          exit 1
        end
        client = HTTP::Client.new("127.0.0.1", port)
        client.connect_timeout = 1
        client.read_timeout = 1
        begin
          response = client.head("/.health")
          exit response.status_code == 200 ? 0 : 1
        rescue IO::TimeoutError
          exit 1
        end
      end
    end
    if settings_path.empty?
      settings_path = File.join(File.dirname(PROGRAM_NAME), "config.json")
    end
    if !File.exists?(settings_path) || !File.readable?(settings_path)
      abort "No settings file found, or it was unreadable (looked for: #{settings_path})"
    end

    settings = File.open(settings_path) { |f| Config.from_json f }
    settings.port = ENV.fetch("PORT", settings.port.to_s).to_u16
    settings.root = ENV.fetch("ROOT", settings.root)
    settings.root = File.realpath(File.expand_path(settings.root))
    settings
  end
end

Settings = Config.load
Kemal.config.app_name = "Zwip"
Kemal.config.powered_by_header = false
Kemal.config.logger = JsonLogHandler.new Settings.log
Kemal.config.shutdown_message = false
Kemal.config.port = Settings.port.to_i32
Kemal.config.env = Settings.kemal_env
serve_static false
MIME.register ".ico", "image/x-icon" # only really needed for the favicon

Signal::TERM.trap do
  Kemal.stop
  exit
end
