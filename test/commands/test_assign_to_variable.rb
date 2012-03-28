require 'test/unit'
require 'commands/assign_to_variable'

class CommandsAssignToVariableTestCase < Test::Unit::TestCase

  def test_should_assign_numbers
    command = AssignToVariable.parse?("$VAR = 237")
    assert_equal('$this->receiver->set_detail("\$VAR", 237);', command.code)
    command = AssignToVariable.parse?("$VAR=237")
    assert_equal('$this->receiver->set_detail("\$VAR", 237);', command.code)
  end
  
  def test_should_assign_other_variables
    command = AssignToVariable.parse?("$VAR = $TMP")
    assert_equal('$this->receiver->set_detail("\$VAR", $this->receiver->get_detail("\$TMP"));', command.code)
  end
  
  def test_should_assign_itself
    command = AssignToVariable.parse?("$VAR = $VAR * $VAR")
    assert_equal('$this->receiver->set_detail("\$VAR", $this->receiver->get_detail("\$VAR") * $this->receiver->get_detail("\$VAR"));', command.code)    
  end
  
  def test_should_assign_complex_formulas
    command = AssignToVariable.parse?("$VAR = (100 * $TMP + 23) / 15 + $VAR")
    assert_equal('$this->receiver->set_detail("\$VAR", (100 * $this->receiver->get_detail("\$TMP") + 23) / 15 + $this->receiver->get_detail("\$VAR"));', command.code)
  end
  
  def test_should_assign_random_values
    command = AssignToVariable.parse?("$RANDOM = Tilfeldig: 2 til 4")
    assert_equal('$this->receiver->set_to_random("\$RANDOM", 2, 4);', command.code)
  end
  
  def test_should_assign_random_values_with_vars
    command = AssignToVariable.parse?("$RANDOM = Tilfeldig: 0 til $MAX")
    assert_equal('$this->receiver->set_to_random("\$RANDOM", 0, $this->receiver->get_detail("\$MAX"));', command.code)
    command = AssignToVariable.parse?("$RANDOM = Tilfeldig: $MIN til $MAX")
    assert_equal('$this->receiver->set_to_random("\$RANDOM", $this->receiver->get_detail("\$MIN"), $this->receiver->get_detail("\$MAX"));', command.code)
  end
  
  def test_should_add_if_known_value
    command = AssignToVariable.parse?("$VAR = $VAR + 4")
    assert_equal('$this->receiver->add_to_detail("\$VAR", 4);', command.code)
  end

  def test_should_set_if_unknown_value
    command = AssignToVariable.parse?("$VAR = $VAR + $TMP")
    assert_equal('$this->receiver->set_detail("\$VAR", $this->receiver->get_detail("\$VAR") + $this->receiver->get_detail("\$TMP"));', command.code)
  end
  
  def test_should_increment_value
    command = AssignToVariable.parse?("$VAR++")
    assert_equal('$this->receiver->add_to_detail("\$VAR", 1);', command.code)
  end

  def test_should_decrease_value
    command = AssignToVariable.parse?("$VAR--")
    assert_equal('$this->receiver->add_to_detail("\$VAR", -1);', command.code)
  end

end