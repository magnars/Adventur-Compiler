# -*- coding: utf-8 -*-
require 'test/unit'
require 'conditional'

class ConditionalTestCase < Test::Unit::TestCase

  def test_should_parse_true
    assert_equal("true", Conditional.parse("-").code)
  end

  def test_should_know_dates
    assert_equal('date("H") > 4 && date("dm") == "3110"', Conditional.parse("DATO3110").code)
    assert_equal('date("H") > 4 && date("dm") == "0505"', Conditional.parse("DATO0505").code)
  end

  def test_should_parse_alternative_number_conditionals
    assert_equal('$visible_alternatives <= 0', Conditional.parse("*0*").code)
  end

  def test_should_parse_flags
    assert_equal('$this->receiver->has_flag("FLAG")',
                 c = Conditional.parse("FLAG").code)
  end

  def test_should_parse_not_statements
    assert_equal('!($this->receiver->has_flag("FLAG"))',
                 Conditional.parse([:not, "FLAG"]).code)
  end

  def test_should_parse_and_statements
    assert_equal('($this->receiver->has_flag("FLAG") && $this->receiver->has_flag("REQUIREMENT"))',
                 Conditional.parse([:and, "FLAG", "REQUIREMENT"]).code)
  end

  def test_should_parse_all_statements
    assert_equal('($this->receiver->has_flag("FLAG") && $this->receiver->has_flag("JAPP") && $this->receiver->has_flag("BANAN"))',
                 Conditional.parse([:all, "FLAG", "JAPP", "BANAN"]).code)
  end

  def test_should_parse_or_statements
    assert_equal('($this->receiver->has_flag("FLAG") || $this->receiver->has_flag("REQUIREMENT"))',
                 Conditional.parse([:or, "FLAG", "REQUIREMENT"]).code)
  end

  def test_should_parse_some_statements
    assert_equal('($this->receiver->has_flag("FLAG") || $this->receiver->has_flag("JAPP") || $this->receiver->has_flag("BANAN"))',
                 Conditional.parse([:some, "FLAG", "JAPP", "BANAN"]).code)
  end

  def test_should_parse_this_but_not_that_statements
    assert_equal('($this->receiver->has_flag("FLAG") && !$this->receiver->has_flag("REQUIREMENT"))',
                 Conditional.parse([:this_but_not_that, "FLAG", "REQUIREMENT"]).code)
  end

  def test_should_parse_not_this_without_that_statements
    assert_equal('(!$this->receiver->has_flag("FLAG") || $this->receiver->has_flag("REQUIREMENT"))',
                 Conditional.parse([:not_this_without_that, "FLAG", "REQUIREMENT"]).code)
  end

  def test_should_parse_values
    assert_equal('$this->receiver->get_detail("\$VALUE") > 0', Conditional.parse("$VALUE").code)
    assert_equal('$this->receiver->get_detail("\$VALUE") >= 12', Conditional.parse("$VALUE >= 12").code)
    assert_equal('$this->receiver->get_detail("\$VALUE") != 4', Conditional.parse("$VALUE != 4").code)
    assert_equal('23 < $this->receiver->get_detail("\$SECOND_VALUE")', Conditional.parse("23 < $SECOND_VALUE").code)
    assert_equal('$this->receiver->get_detail("\$VALUE") == $this->receiver->get_detail("\$SECOND_VALUE")', Conditional.parse("$VALUE == $SECOND_VALUE").code)
    assert_equal('$this->receiver->get_detail("\$HØYBORG") < -531243', Conditional.parse("$HØYBORG < -531243").code)
    assert_equal('$this->receiver->get_detail("\$TIDSPUNKT") > 2 + $this->receiver->get_detail("\$HØRTE_SISTE_RYKTE")', Conditional.parse("$TIDSPUNKT > 2 + $HØRTE_SISTE_RYKTE").code)
    assert_equal('$this->receiver->get_detail("\$TIDSPUNKT") > $this->receiver->get_detail("\$HØRTE_SISTE_RYKTE") + 2', Conditional.parse("$TIDSPUNKT > $HØRTE_SISTE_RYKTE + 2").code)
    assert_equal('$this->receiver->get_detail("\$VALUE") + 7 >= 12', Conditional.parse("$VALUE + 7 >= 12").code)
  end

  def test_should_inject_dates
    assert_equal('date("m") == 12', Conditional.parse("$_MND == 12").code)
    assert_equal('date("H") > 4 && date("d") < 24', Conditional.parse("$_DATO < 24").code)
    assert_equal('(date("m") == 12 && date("H") > 4 && date("d") < 24)', Conditional.parse([:and, "$_MND == 12", "$_DATO < 24"]).code)
  end

  def test_should_parse_mixed
    assert_equal('($this->receiver->has_flag("PØLSE") && ($this->receiver->get_detail("\$TIDSPUNKT") > 7 && $this->receiver->has_flag("ÆLG")))',
                 Conditional.parse([:and, "PØLSE", [:and, "$TIDSPUNKT > 7", "ÆLG"]]).code)
  end

  def test_should_allow_numbers
    assert_equal('$this->receiver->get_detail("]C[TEST") == -245371941', ValueConditional.new("]C[TEST", "==", -245371941).code)
  end

  def test_should_know_kongerupi
    assert_equal('$this->receiver->get_detail("\$_KONGERUPI") >= 12', Conditional.parse("kr.12").code)
  end

end
