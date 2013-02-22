module TrafficLights
  
  class Server
    
    require 'net/ssh'
    require 'wiringpi'
    
    attr_accessor :gpio, :name
    
    def initialize config={}
      @config = config
      @gpio = config[:gpio] || []
      @name = config[:name] || ""
      @active_gpio = false
      @io = WiringPi::GPIO.new
      
      @gpio.each do |pin|
        puts "TURN %d OUTPUT" % pin
        @io.mode(pin, OUTPUT)
      end
    end
    
    def start
      Net::SSH.start(@config[:ssh][:host], @config[:ssh][:user], @config[:ssh][:options]) do |ssh|
        cmd = "while true; do L=$(awk '{ print $1 }' /proc/loadavg); D=$(date +%H:%M:%S); echo -e \"$D\t$L\"; sleep 2; done"
        channel = ssh.open_channel do |chan|
          chan.exec(cmd) do |ch, success|
            raise "Could not execute command on SSH channel." unless success
            
            ch.on_data do |c, data|
              handle_data data
            end
            
            ch.on_close do 
              puts "done!"
            end
          end
        end
        begin
          channel.wait
        rescue SystemExit, Interrupt
          puts "Turning off leds for %s" % @name
          @gpio.each do |pin|
            @io.write(pin, 0)
          end
          exit
        end
        
      end
    end
  
  def load_percentage load_value
    load_value.to_f / @config[:cpu_cores] * 100
  end
  
  def load_gpio_index load_value
    perc = load_percentage load_value
    gpio_index = 0
    gpio_index += 1 if perc >= @config[:limits].first
    
    if (@config[:type] == :trafficlights)        
      gpio_index += 1 if perc >= @config[:limits].last
    end
    gpio_index
  end
  
  def load_gpio load_value
    gpio_index = load_gpio_index load_value
    @gpio[gpio_index]
  end
  
  private
    def handle_data data
      _date, _load = data.split("\t")
      puts @name + " " + _date
      puts _load
      
      load = _load.to_f
      enlighten load_gpio(load)
    end
    
    def enlighten pin
      if @gpio_active != pin
        (@gpio - [ pin ]).each do |inactive_pin|
          #TODO turn off this gpio pin
          puts "TURN %d OFF" % inactive_pin
          @io.write(inactive_pin, 0)
        end
        @gpio_active = pin
        # TODO turn on this gpio pin
        puts "TURN %d ON" % pin
        @io.write(pin, 1)
      end
    end
  end
end