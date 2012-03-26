# -*- coding: utf-8 -*-
require 'test/unit'
require 'commands/plain_text'

class CommandsPlainTextTestCase < Test::Unit::TestCase

  def setup
    @text = PlainText.parse?("a line of prose")
  end

  def test_should_parse_anything
    assert(PlainText.parse?("any line of text"), "PlainText should accept anything.")
  end

  def test_should_build_code
    assert_equal('$this->receiver->write("a line of prose");', @text.code)
  end

  def test_should_not_add_spaces_after_every_80_chars_anymore
    assert_equal('$this->receiver->write("\"..og for å skape en troverdig front for dette mørkeste av ritualer, så skal de laveste medlemmene av banklosjen arrangere en liksomfest med liksompunsj og     liksomdansing etterpå. For en farse! Hadde det ikke vært for mitt dårlige kne så skulle jeg satt en stopper for det mørke ritualet selv.\" Sjømannen nikker ivrig, veldig enig med seg selv.");',
                 PlainText.parse?('"..og for å skape en troverdig front for dette mørkeste av ritualer, så skal de laveste medlemmene av banklosjen arrangere en liksomfest med liksompunsj og     liksomdansing etterpå. For en farse! Hadde det ikke vært for mitt dårlige kne så skulle jeg satt en stopper for det mørke ritualet selv." Sjømannen nikker ivrig, veldig enig med seg selv.').code)
  end

  def test_should_escape_quotation_marks
    assert_equal('$this->receiver->write("\"Hello,\" he said.");', PlainText.new("\"Hello,\" he said.").code)
  end

  def test_should_escape_backslash
    # denne sinnsyke mengden backslasher er det som skal til for å få et dobbelt sett helt ut til eksporten..
    assert_equal('$this->receiver->write("Backslash: \\\\\\\\\");', PlainText.new("Backslash: \\").code)
  end

  def test_should_insert_nickname
    assert_equal('$this->receiver->write("You are known as ".$this->receiver->get_nickname()." the great.");',
                 PlainText.new("You are known as <navn> the great.").code)
  end

end
