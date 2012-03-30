# -*- coding: utf-8 -*-
require 'test/unit'
require 'cond_tree'

class CondTreeTestCase < Test::Unit::TestCase

  def test_parse_flags
    assert_equal("BØLLE", CondTree.parse("BØLLE"))
    assert_equal("AKTIVT_RYKTE:HUSKER_I_TREET", CondTree.parse("AKTIVT_RYKTE:HUSKER_I_TREET"))
  end

  def test_parse_nots
    assert_equal([:not, "BØLLE"], CondTree.parse("ikke BØLLE"))
  end

  def test_replace_with_oldies
    assert_equal("DATO2412", CondTree.parse("den 24/12"))
  end

  def test_replace_with_oldies
    assert_equal("_BESØK_3", CondTree.parse("3. besøk"))
  end

  def test_parse_all_two
    assert_equal([:all, "TØY", "DATO0412"],
                 CondTree.parse("både TØY og den 04/12"))
  end

  def test_parse_all_more
    assert_equal([:all, "TØY1", "TØY2", "*1*"],
                 CondTree.parse("både TØY1, TØY2 og 2. alternativ"))
  end

  def test_parse_all_with_expressions
    assert_equal([:all, "$SAMUELSEN == 1", "HØRER-VÅPENHUS"],
                 CondTree.parse("både $SAMUELSEN == 1 og HØRER-VÅPENHUS"))
  end

  def test_parse_all_with_nr_and_kr
    assert_equal([:all, "nr10825", "kr.19"],
                 CondTree.parse("både nr10825 og kr.19"))
  end


  def test_parse_some
    assert_equal([:some, "TØY1", "TØY2", "*1*"],
                 CondTree.parse("enten TØY1, TØY2 eller 2. alternativ"))
  end

  def test_parse_some_with_expressions
    assert_equal([:some, "$SAMUELSEN == 1", "HØRER-VÅPENHUS"],
                 CondTree.parse("enten $SAMUELSEN == 1 eller HØRER-VÅPENHUS"))
  end

  def test_strip_parens
    assert_equal("BØLLE", CondTree.parse("(BØLLE)"))
  end

  def test_parse_but_without_parens
    assert_equal([:this_but_not_that, "BØY1", "BØY2"],
                 CondTree.parse("BØY1, men ikke BØY2"))
  end

  def test_parse_but_without_parens_complex
    assert_equal([:this_but_not_that, [:all, "PÅ1", "PÅ2", "PÅ3"], [:all, "PÅ4", "PÅ5"]],
                 CondTree.parse("både PÅ1, PÅ2 og PÅ3, men ikke både PÅ4 og PÅ5"))
  end

  def test_parse_not_this_without_that
    assert_equal([:not_this_without_that, "BØY1", "BØY2"],
                 CondTree.parse("ikke BØY1 uten også BØY2"))
  end

  def test_parse_not_this_without_that_complex
    assert_equal([:not_this_without_that, [:some, "PÅ1", "PÅ2"], [:all, "PÅ3", "PÅ4"]],
                 CondTree.parse("verken PÅ1 eller PÅ2 uten også både PÅ3 og PÅ4"))
  end

  def test_parse_not_this_without_that_complex_2
    assert_equal([:not_this_without_that, [:some, "PÅ1", "PÅ2"], [:and, "PÅ3", "PÅ4"]],
                 CondTree.parse("verken PÅ1 eller PÅ2 uten også PÅ3 og PÅ4"))
  end

  def test_parse_and
    assert_equal([:and, "TØY1", "TØY2"], CondTree.parse("TØY1 og TØY2"))
  end

  def test_parse_values
    assert_equal("$VALUE", CondTree.parse("$VALUE"))
    assert_equal("$VALUE >= 12", CondTree.parse("$VALUE >= 12"))
    assert_equal("$VALUE != 4", CondTree.parse("$VALUE != 4"))
    assert_equal("23 < $SECOND_VALUE", CondTree.parse("23 < $SECOND_VALUE"))
    assert_equal("$VALUE == $SECOND_VALUE", CondTree.parse("$VALUE == $SECOND_VALUE"))
    assert_equal("$HØYBORG < -531243", CondTree.parse("$HØYBORG < -531243"))
    assert_equal("$TIDSPUNKT > 2 + $HØRTE_SISTE_RYKTE", CondTree.parse("$TIDSPUNKT > 2 + $HØRTE_SISTE_RYKTE"))
    assert_equal("$TIDSPUNKT > $HØRTE_SISTE_RYKTE + 2", CondTree.parse("$TIDSPUNKT > $HØRTE_SISTE_RYKTE + 2"))
    assert_equal("$VALUE + 7 >= 12", CondTree.parse("$VALUE + 7 >= 12"))
  end

  def test_parse_and_more
    assert_equal([:and, "TØY0", [:and, "TØY1", "TØY2"]],
                 CondTree.parse("TØY0 og TØY1 og TØY2"))
  end

  def test_parse_parens
    assert_equal([:and, [:not, "PÅ1"], [:all, "PÅ2", "PÅ3"]],
                 CondTree.parse("(ikke PÅ1) og (både PÅ2 og PÅ3)"))
  end

  def test_parse_and_without_parens
    assert_equal([:and, [:not, "PÅ1"], [:all, "PÅ2", "PÅ3"]],
                 CondTree.parse("ikke PÅ1 og både PÅ2 og PÅ3"))
  end

  def test_parse_equals_and
    assert_equal([:and, [:not, "PÅ1"], [:all, "PÅ2", "PÅ3"]],
                 CondTree.parse("ikke PÅ1, men både PÅ2 og PÅ3"))
  end

  def test_parse_basic_or
    assert_equal([:or, "TØY1", "TØY2"],
                 CondTree.parse("TØY1 eller TØY2"))
  end

  def test_parse_or_with_parens
    assert_equal([:or, [:not, "PÅ1"], [:all, "PÅ2", "PÅ3"]],
                 CondTree.parse("(ikke PÅ1) eller (både PÅ2 og PÅ3)"))
  end

  def test_parse_or_without_parens
    assert_equal([:or, [:not, "PÅ1"], [:all, "PÅ2", "PÅ3"]],
                 CondTree.parse("ikke PÅ1 eller både PÅ2 og PÅ3"))
  end

  def test_parens_needed
    assert_equal([:and, [:or, "Æ1", "Æ2"], [:or, "Æ3", "Æ4"]],
                 CondTree.parse("(Æ1 eller Æ2) og (Æ3 eller Æ4)"))
  end

  def test_parens_skipped
    assert_equal([:or, "Æ1", [:and, "Æ2", [:or, "Æ3", "Æ4"]]],
                 CondTree.parse("Æ1 eller Æ2 og Æ3 eller Æ4"))
  end

  def test_not_all
    assert_equal([:not, [:all, "FØY1", "FØY2"]],
                 CondTree.parse("ikke både FØY1 og FØY2"))
  end

  def test_not_some
    assert_equal([:not, [:some, "FØY1", "FØY2"]],
                 CondTree.parse("ikke enten FØY1 eller FØY2"))
  end

  def test_neither
    assert_equal([:not, [:some, "FØY1", "FØY2"]],
                 CondTree.parse("verken FØY1 eller FØY2"))
  end

  def test_neither_with_parens
    assert_equal([:not, [:some, "FØY1", "FØY2"]],
                 CondTree.parse("(verken FØY1 eller FØY2)"))
  end

  def test_not_neither_with_parens
    assert_equal([:not, [:not, [:some, "FØY1", "FØY2"]]],
                 CondTree.parse("ikke (verken FØY1 eller FØY2)"))
  end

end
