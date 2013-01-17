module TrafficLights
  
  class Starter
    
    require 'yaml'
    
    DEFAULT_CONFIG = {
      cpu_cores: 1,
      limits: [60,90],
      type: :trafficlights,
      ssh: {
        port: 22
      }
    }
    
    def initialize
      @gpio_available = (0..7).to_a
      @servers   = []
      
      read_config    
    end
    
    def read_config
      raw_config = File.read("./config/config.yml")
      @config = YAML.load(raw_config)
  
      @config.each_pair do |key, value|
        value = keys_to_symbols(value)
        
        value = DEFAULT_CONFIG.merge(value)     
        
        value[:name] = key unless value.has_key? :name
        
        
        print value
        
        case value[:type]
        when :redgreen
          needs_gpio = 2
        when :trafficlights
          needs_gpio = 3
        end
        
        raise "unsufficient gpio pins available" if needs_gpio > @gpio_available.length
        
        value[:gpio] = @gpio_available.shift(needs_gpio)
        
        @servers << TrafficLights::Server.new(value)
      end
    end
    
    def gpio_used
      @servers.collect{|s| s.gpio}.flatten
    end
    
    def test
      gpio = gpio_used
      puts "Make sure you have connected GPIO pins " + gpio.join(", ")
      puts "Testing lights per config entry"
      @servers.each do |server|
        puts "Server: " + server.name
        server.gpio.each do |pin|
          #TODO switch pin to output mode
          #TODO switch pin on
          puts "GPIO pin %d ON" % pin
          #TODO switch pin off
          puts "GPIO pin %d OFF" % pin
        end
      end
    end
    
    def start
      @servers.each do |server|
        server.start
      end
    end
    
    private
      def keys_to_symbols(hash)
        Hash[hash.keys.map do |k|
          raise "illegal key #{k.inspect}" unless k.respond_to?(:to_sym)
          h = hash[k]
          h = keys_to_symbols h if h.is_a? Hash
          [k.to_sym, h]
        end]
      end
    
  end
end