require "./config.cr"

Kemal.config.port = ENV.fetch("PORT", "3000").to_i

Kemal.run
