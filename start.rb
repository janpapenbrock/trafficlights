require 'net/ssh'
require 'yaml'
require './lib/traffic_lights.rb'

t = TrafficLights::Starter.new
t.test
t.start