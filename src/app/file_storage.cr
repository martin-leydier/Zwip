require "baked_file_system"

class FileStorage
  START_TIME = Time.local
  BakedFileSystem.load("../../public", __DIR__)

  def self.serve(file, ctx)
    req = ctx.request
    resp = ctx.response
    resp.status_code = 200
    resp.content_type = MIME.from_filename(file.path, "text/html")
    last_modified = START_TIME
    add_cache_headers(resp.headers, START_TIME)
    if cache_request?(ctx, START_TIME)
      resp.status_code = 304
      return
    end
    if req.headers["Accept-Encoding"]? =~ /gzip/
      resp.headers["Content-Encoding"] = "gzip"
      resp.content_length = file.compressed_size
      file.write_to_io(resp, compressed: true)
    else
      resp.content_length = file.size
      file.write_to_io(resp, compressed: false)
    end
  end

  # Function from crystal's HTTP::StaticFileHandler
  private def self.add_cache_headers(response_headers : HTTP::Headers, last_modified : Time) : Nil
    response_headers["Etag"] = etag(last_modified)
    response_headers["Last-Modified"] = HTTP.format_time(last_modified)
    response_headers["Cache-Control"] = "public,max-age=31536000"
  end

  # Function from crystal's HTTP::StaticFileHandler
  private def self.cache_request?(context : HTTP::Server::Context, last_modified : Time) : Bool
    # According to RFC 7232:
    # A recipient must ignore If-Modified-Since if the request contains an If-None-Match header field
    if if_none_match = context.request.if_none_match
      match = {"*", context.response.headers["Etag"]}
      if_none_match.any? { |etag| match.includes?(etag) }
    elsif if_modified_since = context.request.headers["If-Modified-Since"]?
      header_time = HTTP.parse_time(if_modified_since)
      # File mtime probably has a higher resolution than the header value.
      # An exact comparison might be slightly off, so we add 1s padding.
      # Static files should generally not be modified in subsecond intervals, so this is perfectly safe.
      # This might be replaced by a more sophisticated time comparison when it becomes available.
      !!(header_time && last_modified <= header_time + 1.second)
    else
      false
    end
  end

  # Function from crystal's HTTP::StaticFileHandler
  private def self.etag(modification_time)
    %{W/"#{modification_time.to_unix}"}
  end
end
