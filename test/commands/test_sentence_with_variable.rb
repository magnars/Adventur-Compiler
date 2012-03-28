require 'test/unit'
require 'rubygems'
require 'mocha'
require 'commands/sentence_with_variable'
require 'room'

class CommandsSentenceWithVariableTestCase < Test::Unit::TestCase

  def setup
    room = ['[$]$VAL', '$$ vals is "roughly" $$ vals.', 'Single val.'].extend(Room)
    @command = SentenceWithVariable.parse?(room.current, room)
  end

  def test_should_generate_code
    assert_equal(expected_code, @command.code)
  end

  private
  
  def expected_code
    [
      "$value = $this->receiver->get_detail_to_display('$VAL');",
      "if ($value == 1) {",
      '  $this->receiver->write("Single val.");',
      "} else if ($value) {",
      "  if (is_numeric($value)) { $value = TextFormatter::number($value); }",
      "  $lvalue = TextFormatter::lowercase($value);",
      '  $this->receiver->write("$value vals is \\"roughly\\" $lvalue vals.");',
      "}"
    ]
  end
end