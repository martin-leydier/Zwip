class JsonLogHandler < Kemal::BaseLogHandler
  @builder : JSON::Builder
  @all_headers : Bool
  @log_headers : Array(String)

  def initialize(@io : IO::FileDescriptor = STDOUT)
    @builder = JSON::Builder.new(@io)
    @builder.indent = "\t" unless Settings.kemal_env == "production"
    @all_headers = Settings.log_headers.any? { |e| e == "*" }
    @log_headers = Settings.log_headers
  end

  def call(context : HTTP::Server::Context)
    elapsed = Time.measure { call_next(context) }
    @builder.document do
      @builder.object do
        @builder.field "time", Time.local.to_s("%Y-%m-%dT%H:%M:%S.%L%:z")
        log_http_context context
        @builder.field "http_status", context.response.status_code
        @builder.field "request_milliseconds", elapsed.total_milliseconds
      end
    end

    @io << '\n'
    @io.flush
    context
  end

  # Only used to log Kemal's log, we chomp the last line feed
  def write(message : String)
    @builder.document do
      @builder.object do
        @builder.field "time", Time.local.to_s("%Y-%m-%dT%H:%M:%S.%L%:z")
        @builder.field "message", message[0..-2]
      end
    end

    @io << '\n'
    @io.flush
  end

  # Used by zwip's log() helper function
  def write_msg(message, context : HTTP::Server::Context? = nil)
    @builder.document do
      @builder.object do
        @builder.field "time", Time.local.to_s("%Y-%m-%dT%H:%M:%S.%L%:z")
        @builder.field "message", message
        log_http_context context unless context.nil?
      end
    end

    @io << '\n'
    @io.flush
  end

  # Tries to guess the request client's IP, based on headers & request address
  # does not trust headers unless specified in Settings
  private def request_ip(request) : String
    if Settings.trust_headers_ip
      hdr = request.headers.fetch("X-Real-Ip", nil)
      return hdr unless hdr.nil?

      hdr = request.headers.fetch("X-Forwarded-For", nil)
      return hdr.split(',')[-1].strip unless hdr.nil?
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
      write_msg({action: "Log file re-opened", path: path})
    end
  end

  # Log misc http values
  private def log_http_context(env : HTTP::Server::Context)
    @builder.field "src_ip", request_ip(env.request)
    @builder.field "http_method", env.request.method
    @builder.field "http_uri_path", env.request.resource
    @builder.field "headers" do
      if @all_headers
        env.request.headers.to_json(@builder)
      else
        @builder.object do
          @log_headers.each do |h|
            @builder.field h, env.request.headers.fetch(h, nil)
          end
        end
      end
    end
  end
end

Signal::USR1.trap do
  Kemal.config.logger.as(JsonLogHandler).reopen
end
