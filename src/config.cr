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

  def load_env(env = ENV)
    Log.debug { "Loading configuration from environment variables..." }
    env["CHEET_PATH"]?.try do |value|
      Log.debug { "Loading path from $CHEET_PATH" }
      newpath = Array(Path).new
      value.split(':') do |part|
        path = Path[part]
        if path.absolute?
          newpath << path
        else
          Log.error { "CHEET_PATH must be absolute" }
        end
        @search_path = newpath unless newpath.empty?
      end
    end
  end
end
