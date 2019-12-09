class JsonLogHandler < Kemal::BaseLogHandler
  @log_headers : Array(String)

  def initialize(@io : IO = STDOUT)
    @log_headers = Settings.log_headers
  end

  private def request_ip(request) : String
    if Settings.trust_forwarded?
      ff_hdr = request.headers.fetch("X-Forwarded-For", nil)
      return ff_hdr.split(',')[0] unless ff_hdr.nil?
    end
    ip_port = request.remote_address
    return "unknown" if ip_port.nil?

    return ip_port.split(':')[0]
  end

  def call(context : HTTP::Server::Context)
    elapsed = Time.measure { call_next(context) }
    @io << "{\"time\":\"" << Time.local.to_s("%Y-%m-%dT%H:%M:%S.%L%:z") << "\","
    @io << "\"src_ip\":\"" << request_ip(context.request) << "\","
    @io << "\"http_status\":" << context.response.status_code << ","
    @io << "\"http_method\":\"" << context.request.method << "\","
    @io << "\"http_uri_path\":" << context.request.resource.to_json << ","
    @io << "\"request_milliseconds\":" << elapsed.total_milliseconds << ","
    @io << "\"headers\":{"
    @log_headers.join(",", @io) do |header, io|
      io << header.to_json << ":" << context.request.headers.fetch(header, "").to_json
    end
    @io << "}}\n"
    @io.flush
    context
  end

  # Only used to log Kemal's log, we chomp the last line feed
  def write(message : String)
    @io << "{\"time\":\"" << Time.local.to_s("%Y-%m-%dT%H:%M:%S.%L%:z") << "\",\"message\": " << message[0..-2].to_json << "}\n"
    @io.flush
  end

  def write_json(message : String)
    @io << "{\"time\":\"" << Time.local.to_s("%Y-%m-%dT%H:%M:%S.%L%:z") << "\",\"message\": " << message << "}\n"
    @io.flush
  end
end
