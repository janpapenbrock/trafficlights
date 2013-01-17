require 'wiringpi'

io = WiringPi::GPIO.new(WPI_MODE_PINS)

io.readAll.keys.each do |pin|
  puts "TURN %d OUTPUT" % pin
  io.mode(pin, OUTPUT)
  sleep 1
  puts "TURN %d ON" % pin
  io.write(pin, 1)
  sleep 1
  puts "TURN %d OFF" % pin
  io.write(pin, 0)
end
