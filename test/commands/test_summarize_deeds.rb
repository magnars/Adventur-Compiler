# -*- coding: utf-8 -*-
require 'test/unit'
require 'rubygems'
require 'mocha'
require 'commands/summarize_deeds'
require 'room'

class CommandsSummarizeDeedsTestCase < Test::Unit::TestCase

  def setup
    enterpreter = mock('enterpreter')
    keeper = mock('hashcode_keeper')
    enterpreter.stubs(:hashcode_keeper).returns(keeper)
    keeper.stubs(:contentlist_for).returns([content_mock('"Slemt altså"', [608088895])], [content_mock('Snilt også', [224333227]), content_mock('Mer snilt', [739606083])])

    @command = SummarizeDeeds.parse?(":gud-og-satan-krangler", nil, enterpreter)
  end

  def content_mock(text, codes)
    content = mock('content')
    content.stubs(:text).returns(text)
    content.stubs(:codes).returns(codes)
    content
  end

  def test_should_generate_code
    assert_equal(expected_code, @command.code)
  end

  def expected_code
    [
      '$evil = array();',
      '$good = array();',
      '$seed = 0;',
      'if ($this->con($this->receiver->has_flag("_EVIL_DEED_608088895"))) { $evil[] = "\\"Slemt altså\\" "; $seed += 608; }',
      'if ($this->con($this->receiver->has_flag("_GOOD_DEED_224333227"))) { $good[] = "Snilt også "; $seed += 224; }',
      'if ($this->con($this->receiver->has_flag("_GOOD_DEED_739606083"))) { $good[] = "Mer snilt "; $seed += 739; }',
      'srand($seed);',
      'while (sizeof($good) > 0) {',
      '  $r = array_rand($good);',
      '  $this->receiver->write($good[$r]);',
      '  unset($good[$r]);',
      '  if (sizeof($evil) > 0) {',
      '    $r = array_rand($evil);',
      '    $this->receiver->write($evil[$r]);',
      '    unset($evil[$r]);',
      '  } else {',
      '    break;',
      '  }',
      '}'
    ]
  end

end
