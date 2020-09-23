.PHONY: dev all shards run

all: run

shards:
	shards check || shards install

run: shards
	crystal run -s -p -t src/zwip.cr

dev/sentry.cr: shards
	curl -fsSLo- https://raw.githubusercontent.com/samueleaton/sentry/master/install.cr | crystal eval

dev: dev/sentry.cr
	crystal dev/sentry_config.cr

release:
	shards --production build --release -s -p -t

release_static:
	shards --production build --release --static -s -p -t
