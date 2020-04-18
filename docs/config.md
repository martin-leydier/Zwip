# Configuring Zwip

At startup, Zwip will look for a config.json file in the same folder as the binary. You can also set an alternative config path using the `-c PATH` or `--config PATH` command line option.

The file sets multiple options for the application runtime. Here is the default file:
```JSON
{
  "root": "/var/www",
  "port": 3000,
  "zip_path": "/usr/bin/zip",
  "log_path": null,
  "trust_headers_ip": false,
  "log_headers": [ "User-Agent", "Referer" ],
  "kemal_env": "production"
}
```

Here is a quick recap of each configuration option:

root
: string
: can be overridden using the ROOT environment variable
: Base directory for the listing, essentially the root directory of what will be exposed

port
: integer
: can be overridden using the PORT environment variable
: Port to listen to, Zwip will listen incoming requests at http://0.0.0.0:port/

zip_path
: string or null
: Path to the zip(1) binary, if it is null or empty, then Zwip will search the PATH for it

log_path
: string or null
: Path to to a file Zwip will log incoming requests and actions to. If it is empty, Zwip will log to STDOUT

trust_headers_ip
: boolean
: Whether or not to trust the incoming HTTP headers X-Real-IP and X-Forwarded-For to deduce the client's IP, this should be set according to your reverse proxy settings (if any). If unsure, leave it to false

log_headers
: array of strings
: When logging requests, Zwip will additionally log the values of each request header specified in this option

kemal_env
: string
: value to pass as the running environment to kemal. You should leave this as production.
