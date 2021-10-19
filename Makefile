.PHONY: dev all shards run

all: run

shards:
	shards check || shards install

run: shards
	crystal run -s -p -t --error-trace src/zwip.cr -- -c "$(shell pwd)/dev/config_dev.json"

sentry:
	curl -fsSLo- https://raw.githubusercontent.com/samueleaton/sentry/master/install.cr | crystal eval

dev: sentry shards
	./sentry -b "crystal build --error-trace ./src/zwip.cr -o ./bin/zwip" -n "Zwip" -r "./bin/zwip" --run-args="-c $(shell pwd)/dev/config_dev.json" -w "./src/**/*.cr" -w "./src/**/*.slang" -w "./public/**/*"

release:
	shards --production build --release -s -p -t

release_static:
	shards --production build --release --static -s -p -t
