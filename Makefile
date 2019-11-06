.PHONY: dev all shards run

all: run

shards:
	shards install

run: shards
	crystal src/zwip.cr

dev/sentry.cr: shards
	curl -fsSLo- https://raw.githubusercontent.com/samueleaton/sentry/master/install.cr | crystal eval

dev: dev/sentry.cr
	crystal dev/sentry_config.cr

release:
	shards build --release

release_static:
	shards build --release --static
