module Trema
  class Settings
    def initialize(root=nil)
      @root = root || Pathname.new(Dir.pwd).join('.trema')
      @config = load_config
    end

    def [](key)
      @config[key]
    end

    def []=(key,value)
      @config[key] = value
    end

    def create_default
      FileUtils.mkdir_p(@root) unless FileTest.exist?(@root)
      File.open(config_file, 'w') do |file|
        file.puts "TREMA_HOME: #{Dir.pwd}"
      end
    end

    def config_file
      Pathname.new(@root).join('config')
    end

    private

    def load_config
      if config_file && config_file.exist?
        Hash[config_file.read.scan(/^(TREMA_.+): ['"]?(.+?)['"]?$/)]
      else
        {}
      end
    end
  end

  def self.settings
    @settings ||= Settings.new
  end
end
