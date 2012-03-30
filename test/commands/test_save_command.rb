require 'test/unit'
require 'rubygems'
require 'mocha'
require 'commands/save_command'
require 'room'
require 'commands/plain_text'

class CommandsSaveCommandTestCase < Test::Unit::TestCase

  def setup
    @enterpreter = mock('enterpreter')
    @keeper = mock('hashcode_keeper')
    @enterpreter.stubs(:hashcode_keeper).returns(@keeper)
  end

  def test_should_save_hash_of_command_to_details
    @keeper.stubs(:code_for).returns(-245371941)
    room = ['MY-SAVED.TEST => contents1'].extend(Room)

    command = SaveCommand.parse?(room.current, room, @enterpreter)

    assert_equal('$this->receiver->set_detail("]C[MY-SAVED.TEST", "-245371941");', command.code)
  end

  def test_should_not_match_other_commands
    assert(!SaveCommand.parse?(":slem => Du er slem"))
  end


end
