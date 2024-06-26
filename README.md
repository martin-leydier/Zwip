# Zwip

A simple HTTP file server. Supports easy grouping of file downloads and zip streaming.

## Features

- HTTP file listing.
- File download selection via a cart system.
- 2 download options:
  - Streamed zip download, to avoid buffering.
  - Multi-link download, automatically start 1 download/per file (though folders are still zipped).
- Do not need Javascript for basic usage, but make use of it to better the experience.


## Demo

A live demo is running over there: https://zwip.onrender.com. In the demo, the root is set as `/`

[![](/docs/images/Zwip.png?raw=true "https://zwip.herokuapp.com")](https://zwip.onrender.com)

## Requirements

* [Crystal](https://crystal-lang.org/) 1.11.2

## Configuring

Zwip can be configured using a simple JSON file. The options are detailed in the docs folder: [config.md](docs/config.md)

## Running & building

Running is rather easy:

```shell
$ git clone https://github.com/martin-leydier/Zwip.git
$ cd Zwip
$ make run
```

You can build the binary using the `release` rule. Avoid using the recipe `release_static` unless on Alpine Linux, this is a crystal limitation.
Building will produce a `Zwip` binary in the bin folder. This is all that's needed (along with some crystal dynamic dependencies `ldd(1)` is your best friend at this point). All static files (css/js/fonts...) are baked into the binary.

## Deploy

You have multiple options:
- as a service
- as a docker container

### Service

1. Build Zwip using `make release`
2. Install Zwip to a location of your choice (/usr/bin/Zwip might be a good choice)
3. Edit and copy the config file to a suitable location (/etc/Zwip.json for example)
4. Setup a simple systemd service (or whatever is your init system of choice). A sample one is provided in the docs folder: [Zwip.service](docs/Zwip.service)
5. `$ sudo systemctl daemon-reload`
6. `$ sudo systemctl enable Zwip.service`
7. `$ sudo systemctl start Zwip.service`

### Docker

You can also deploy Zwip using the provided docker image, either by pulling it from the docker hub or by building it yourself.
The final image is built from scratch and only contains Zwip. It runs Zwip as an unprivileged user id 12345 and group id 12345.
It is recommended to change it to a more appropriate uid:gid for your setup using the --user directive of docker.
The image also contains the default config.json.

Using the command line:
```shell
$ sudo docker run -p 3000:3000 -v /var/www:/var/www:ro -v "$(pwd)/config.json:/config.json:ro" --user 12345:12345 --cap-drop=all --security-opt=no-new-privileges:true martinleydier/zwip
```

In a docker-compose.yml:
```yaml
version: "3"
services:
  zwip:
    image: martinleydier/zwip
    ports:
      - "3000:3000"
    volumes:
      - "/var/www:/var/www:ro"
      - "./config.json:/config.json:ro"
    user: "12345:12345"
    cap_drop:
      - all
    security_opt:
      - no-new-privileges:true
    ulimits:
      nproc: 2 # server & healthcheck
    hostname: zwip
    container_name: zwip
    restart: always
```
