class JsonLogHandler < Kemal::BaseLogHandler
  def initialize(@io : IO = STDOUT)
    STDOUT.sync = true if @io == STDOUT
  end

  def call(context : HTTP::Server::Context)
    elapsed = Time.measure { call_next(context) }
    @io << "{\"time\":\"" << Time.now.to_s("%Y-%m-%dT%H:%M:%S.%L%:z") << "\","
    @io << "\"http_status\":" << context.response.status_code << ","
    @io << "\"http_method\":\"" << context.request.method << "\","
    @io << "\"http_uri_path\":" << context.request.resource.to_json << ","
    @io << "\"request_milliseconds\":" << elapsed.total_milliseconds << "}\n"
    context
  end

  def write(message : String)
    @io << "{\"time\":\"" << Time.now.to_s("%Y-%m-%dT%H:%M:%S.%L%:z") << "\",\"message\": " << message.chomp.to_json << "}\n"
  end
end
