require 'test/unit'
require 'rubygems'
require 'mocha'
require 'commands/run_saved_command'
require 'commands/plain_text'
require 'enterpreter'

class CommandsRunSavedCommandTestCase < Test::Unit::TestCase

  def setup
    @room = ['<= TEST'].extend(Room)
    create_enterpreter_mock
  end

  def test_should_build_code
    @keeper.stubs(:contentlist_for).returns([content_mock("contents1", [-245371941]), content_mock("contents2", [-245371940, 123456778])])
    @enterpreter.stubs(:current_command).returns(PlainText.new("contents1"), PlainText.new("contents2"))
    command = RunSavedCommand.parse?(@room.current, @room, @enterpreter)
    assert_equal(['if ($this->con($this->receiver->get_detail("]C[TEST") == -245371941)) {',
                  '  $this->receiver->write("contents1");',
                  '}',
                  'if ($this->con($this->receiver->get_detail("]C[TEST") == -245371940 || $this->receiver->get_detail("]C[TEST") == 123456778)) {',
                  '  $this->receiver->write("contents2");',
                  '}'
                 ], command.code)
  end

  private

  def content_mock(text, codes)
    content = mock('content')
    content.stubs(:text).returns(text)
    content.stubs(:codes).returns(codes)
    content
  end

  def create_enterpreter_mock
    @enterpreter = mock('enterpreter')
    @keeper = mock('hashcode_keeper')
    @enterpreter.stubs(:hashcode_keeper).returns(@keeper)
  end

end
