require "log"

struct Cheet::Config
  property stdout : IO = STDOUT
  property search_path do
    [Path.home / ".local/share/cheet",
    Path.home / ".cheet"]
  end

  def initialize
    Log.info { "Initializing default config" }
  end

  def self.from_env(env = ENV)
    Log.debug { "Loading configuration from environment variables..." }
    config = self.new
    env["CHEET_PATH"]?.try do |value|
      Log.debug { "Loading path from $CHEET_PATH" }
      config.search_path = Array(Path).new
      value.split(':') do |part|
        path = Path[part]
        if path.absolute?
          config.search_path << path
        else
          Log.error { "CHEET_PATH must be absolute" }
        end
      end
    end
    config
  end
end
