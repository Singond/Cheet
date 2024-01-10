require "log"

# Application configuration.
struct Cheet::Config
  property stdout : IO = STDOUT
  property search_path do
    [Path.home / ".local/share/cheet",
    Path.home / ".cheet"]
  end

  def initialize
    Log.trace { "Initializing default config" }
  end

  # Returns a new `Config` with values read from environment variables.
  #
  # The environment can also be specified explicitly as an argument.
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

  # Returns a new `Config` formed by layering the *configs* in arguments.
  # This combines the *configs* arguments into a single struct with values
  # in earlier arguments taking precedence, while ignoring `nil` values.
  # If a field is `nil` in all *configs*, it remains `nil` and will be
  # lazily initialized to default when accessing it.
  def self.layer(*configs)
    layered = Config.new
    {% for attr in @type.instance_vars %}
      configs.each do |c|
        if !c.@{{attr}}.nil?
          layered.{{attr}} = c.@{{attr}}
          break
        end
      end
    {% end %}
    layered
  end
end
