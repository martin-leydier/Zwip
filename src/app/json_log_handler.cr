class JsonLogHandler < Kemal::BaseLogHandler
  @log_headers : Array(String)

  def initialize(@io : IO::FileDescriptor = STDOUT)
    @log_headers = Settings.log_headers
  end

  def call(context : HTTP::Server::Context)
    elapsed = Time.measure { call_next(context) }
    @io << "{\"time\":\"" << Time.local.to_s("%Y-%m-%dT%H:%M:%S.%L%:z") << "\","
    log_http_context context
    @io << ",\"http_status\":" << context.response.status_code << ","
    @io << "\"request_milliseconds\":" << elapsed.total_milliseconds << "}\n"
    @io.flush
    context
  end

  # Only used to log Kemal's log, we chomp the last line feed
  def write(message : String)
    @io << "{\"time\":\"" << Time.local.to_s("%Y-%m-%dT%H:%M:%S.%L%:z") << "\",\"message\": " << message[0..-2].to_json << "}\n"
    @io.flush
  end

  # Used by zwip's log() helper function
  def write_json(message : String, context : HTTP::Server::Context? = nil)
    @io << "{\"time\":\"" << Time.local.to_s("%Y-%m-%dT%H:%M:%S.%L%:z") << "\",\"message\": " << message
    unless context.nil?
      @io << ","
      log_http_context context
    end
    @io << "}\n"
    @io.flush
  end

  # Tries to guess the request client's IP, based on headers & request address
  # does not trust headers unless specified in Settings
  private def request_ip(request) : String
    if Settings.trust_headers_ip
      hdr = request.headers.fetch("X-Real-Ip", nil)
      return hdr unless hdr.nil?

      hdr = request.headers.fetch("X-Forwarded-For", nil)
      return hdr.split(',')[0] unless hdr.nil?
    end
    ip_port = request.remote_address
    return "unknown" if ip_port.nil? || !ip_port.responds_to? :address

    return ip_port.address
  end

  # reopen log file
  def reopen
    log = Settings.log
    if log.responds_to? :path
      path = log.path
      return unless path
      new_io = File.open path, "a"
      @io.reopen(new_io)
      write_json({action: "Log file re-opened", path: path}.to_json)
    end
  end

  # Log misc http values
  private def log_http_context(env : HTTP::Server::Context)
    @io << "\"src_ip\":\"" << request_ip(env.request) << "\","
    @io << "\"http_method\":\"" << env.request.method << "\","
    @io << "\"http_uri_path\":" << env.request.resource.to_json << ","
    @io << "\"headers\":{"
    @log_headers.join(@io, ",") do |header, io|
      io << header.to_json << ":" << env.request.headers.fetch(header, "").to_json
    end
    @io << "}"
  end
end

Signal::USR1.trap do
  Kemal.config.logger.as(JsonLogHandler).reopen
end
