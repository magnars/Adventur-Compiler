# -*- coding: utf-8 -*-
require 'test/unit'
require 'conditional'

class ConditionalTestCase < Test::Unit::TestCase

  def test_should_parse_true
    assert_equal("true", Conditional.build("-").code)
  end

  def test_should_know_dates
    assert_equal('date("H") > 4 && date("dm") == "3110"', Conditional.build("DATO3110").code)
    assert_equal('date("H") > 4 && date("dm") == "0505"', Conditional.build("DATO0505").code)
  end

  def test_should_parse_alternative_number_conditionals
    assert_equal('$visible_alternatives <= 0', Conditional.build("*0*").code)
  end

  def test_should_parse_flags
    assert_equal('$this->receiver->has_flag("FLAG")',
                 c = Conditional.build("FLAG").code)
  end

  def test_should_parse_not_statements
    assert_equal('!($this->receiver->has_flag("FLAG"))',
                 Conditional.build([:not, "FLAG"]).code)
  end

  def test_should_parse_and_statements
    assert_equal('($this->receiver->has_flag("FLAG") && $this->receiver->has_flag("REQUIREMENT"))',
                 Conditional.build([:and, "FLAG", "REQUIREMENT"]).code)
  end

  def test_should_parse_all_statements
    assert_equal('($this->receiver->has_flag("FLAG") && $this->receiver->has_flag("JAPP") && $this->receiver->has_flag("BANAN"))',
                 Conditional.build([:all, "FLAG", "JAPP", "BANAN"]).code)
  end

  def test_should_parse_or_statements
    assert_equal('($this->receiver->has_flag("FLAG") || $this->receiver->has_flag("REQUIREMENT"))',
                 Conditional.build([:or, "FLAG", "REQUIREMENT"]).code)
  end

  def test_should_parse_some_statements
    assert_equal('($this->receiver->has_flag("FLAG") || $this->receiver->has_flag("JAPP") || $this->receiver->has_flag("BANAN"))',
                 Conditional.build([:some, "FLAG", "JAPP", "BANAN"]).code)
  end

  def test_should_parse_this_but_not_that_statements
    assert_equal('($this->receiver->has_flag("FLAG") && !$this->receiver->has_flag("REQUIREMENT"))',
                 Conditional.build([:this_but_not_that, "FLAG", "REQUIREMENT"]).code)
  end

  def test_should_parse_not_this_without_that_statements
    assert_equal('(!$this->receiver->has_flag("FLAG") || $this->receiver->has_flag("REQUIREMENT"))',
                 Conditional.build([:not_this_without_that, "FLAG", "REQUIREMENT"]).code)
  end

  def test_should_parse_values
    assert_equal('$this->receiver->get_detail("\$VALUE") > 0', Conditional.build("$VALUE").code)
    assert_equal('$this->receiver->get_detail("\$VALUE") >= 12', Conditional.build("$VALUE >= 12").code)
    assert_equal('$this->receiver->get_detail("\$VALUE") != 4', Conditional.build("$VALUE != 4").code)
    assert_equal('23 < $this->receiver->get_detail("\$SECOND_VALUE")', Conditional.build("23 < $SECOND_VALUE").code)
    assert_equal('$this->receiver->get_detail("\$VALUE") == $this->receiver->get_detail("\$SECOND_VALUE")', Conditional.build("$VALUE == $SECOND_VALUE").code)
    assert_equal('$this->receiver->get_detail("\$HØYBORG") < -531243', Conditional.build("$HØYBORG < -531243").code)
    assert_equal('$this->receiver->get_detail("\$TIDSPUNKT") > 2 + $this->receiver->get_detail("\$HØRTE_SISTE_RYKTE")', Conditional.build("$TIDSPUNKT > 2 + $HØRTE_SISTE_RYKTE").code)
    assert_equal('$this->receiver->get_detail("\$TIDSPUNKT") > $this->receiver->get_detail("\$HØRTE_SISTE_RYKTE") + 2', Conditional.build("$TIDSPUNKT > $HØRTE_SISTE_RYKTE + 2").code)
    assert_equal('$this->receiver->get_detail("\$VALUE") + 7 >= 12', Conditional.build("$VALUE + 7 >= 12").code)
  end

  def test_should_inject_dates
    assert_equal('date("m") == 12', Conditional.build("$_MND == 12").code)
    assert_equal('date("H") > 4 && date("d") < 24', Conditional.build("$_DATO < 24").code)
    assert_equal('(date("m") == 12 && date("H") > 4 && date("d") < 24)', Conditional.build([:and, "$_MND == 12", "$_DATO < 24"]).code)
  end

  def test_should_parse_mixed
    assert_equal('($this->receiver->has_flag("PØLSE") && ($this->receiver->get_detail("\$TIDSPUNKT") > 7 && $this->receiver->has_flag("ÆLG")))',
                 Conditional.build([:and, "PØLSE", [:and, "$TIDSPUNKT > 7", "ÆLG"]]).code)
  end

  def test_should_allow_numbers
    assert_equal('$this->receiver->get_detail("]C[TEST") == -245371941', ValueConditional.new("]C[TEST", "==", -245371941).code)
  end

  def test_should_know_kongerupi
    assert_equal('$this->receiver->get_detail("\$_KONGERUPI") >= 12', Conditional.build("kr.12").code)
  end

  def test_should_parse_visits
    assert_equal('$this->receiver->get_detail("\$_VISITS_TO_453") == 3',
                 Conditional.build("_BESØK_3", 453).code)
  end


end
