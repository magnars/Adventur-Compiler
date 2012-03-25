require 'test/unit'
require 'rubygems'
require 'mocha'
require 'commands/save_command'
require 'room'
require 'commands/plain_text'

class CommandsSaveCommandTestCase < Test::Unit::TestCase

  def setup
    enterpreter = mock('enterpreter')
    keeper = mock('hashcode_keeper')
    enterpreter.stubs(:hashcode_keeper).returns(keeper)
    keeper.stubs(:code_for).returns(-245371941)

    room = [']C[SAVED', 'contents1'].extend(Room)
    @command = SaveCommand.parse?(room.current, room, enterpreter)
  end

  def test_should_save_hash_of_command_to_details
    assert_equal('$this->receiver->set_detail("]C[SAVED", "-245371941");', @command.code)
  end
  
  

end
