require "./sentry.cr"

sentry = Sentry::ProcessRunner.new(
  display_name: "Zwip",
  build_command: "crystal build ./app.cr -o ./bin/zwip",
  run_command: "./bin/zwip",
  files: ["./*.cr", "./src/**/*.cr", "./src/**/*.slang"]
)
sentry.run
