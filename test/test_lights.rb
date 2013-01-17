require File.dirname(__FILE__) + '/../lib/traffic_lights.rb'

# test percentage
t = TrafficLights::Server.new({ cpu_cores: 2 })
puts t.load_percentage(1) == 50.0
puts t.load_percentage(0.25) == 12.5

t = TrafficLights::Server.new({ cpu_cores: 1, limits: [50], type: :redgreen })
puts t.load_gpio_index(0.1) == 0
puts t.load_gpio_index(0.6) == 1
puts t.load_gpio_index(2) == 1

t = TrafficLights::Server.new({ cpu_cores: 1, limits: [50, 80], type: :trafficlights })
puts t.load_gpio_index(0.1) == 0
puts t.load_gpio_index(0.6) == 1
puts t.load_gpio_index(0.8) == 2
puts t.load_gpio_index(2) == 2

t = TrafficLights::Server.new({ cpu_cores: 1, limits: [50, 80], type: :trafficlights, gpio: [4,5,6] })
puts t.load_gpio(0.1) == 4
puts t.load_gpio(0.6) == 5
puts t.load_gpio(0.8) == 6
puts t.load_gpio(2) == 6
