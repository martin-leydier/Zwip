class JsonLogHandler < Kemal::BaseLogHandler
  @log_headers : Array(String)

  def initialize(@io : IO = STDOUT)
    STDOUT.sync = true if @io == STDOUT
    @log_headers = Settings.log_headers
  end

  def call(context : HTTP::Server::Context)
    elapsed = Time.measure { call_next(context) }
    @io << "{\"time\":\"" << Time.local.to_s("%Y-%m-%dT%H:%M:%S.%L%:z") << "\","
    @io << "\"http_status\":" << context.response.status_code << ","
    @io << "\"http_method\":\"" << context.request.method << "\","
    @io << "\"http_uri_path\":" << context.request.resource.to_json << ","
    @io << "\"request_milliseconds\":" << elapsed.total_milliseconds << ","
    @io << "\"headers\":["
    @log_headers.join(",", @io) do |header, io|
      io << header.to_json << ":" << context.request.headers.fetch(header, "").to_json
    end
    @io << "]}\n"
    context
  end

  # Only used to log Kemal's log, we chomp the last line feed
  def write(message : String)
    @io << "{\"time\":\"" << Time.local.to_s("%Y-%m-%dT%H:%M:%S.%L%:z") << "\",\"message\": " << message[0..-2].to_json << "}\n"
  end

  def write_json(message : String)
    @io << "{\"time\":\"" << Time.local.to_s("%Y-%m-%dT%H:%M:%S.%L%:z") << "\",\"message\": " << message << "}\n"
  end
end
