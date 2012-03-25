require 'room_loader'
require 'page'

abort "Usage: integration_test.rb [rooms folder] [room number]" if ARGV.size < 2
loader = RoomLoader.new ARGV.shift
coordinator = TimedJumpCoordinator.new loader

while number = ARGV.shift
  puts Page.new(number, loader, coordinator).code
end
