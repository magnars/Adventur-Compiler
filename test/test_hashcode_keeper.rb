# -*- coding: utf-8 -*-
require 'test/unit'
require 'hashcode_keeper'

class HashcodeKeeperTestCase < Test::Unit::TestCase

  def setup
    @keeper = HashcodeKeeper.new
    @keeper.add("GI_URTE", "()FIKK-INGEFÆR")
  end

  def teardown
    File.delete("hck_test.txt") if File.exists? "hck_test.txt"
  end

  def test_should_parse_hashcodefile
    keeper = HashcodeKeeper.new hashcodefile
    assert_equal 2, keeper.contentlist_for("KRAV").size
    assert_equal 1, keeper.contentlist_for("VRAK").size
    assert_equal [987, 654, 321], keeper.contentlist_for("VRAK").first.codes
  end

  def test_should_save_hashcodefile
    keeper = HashcodeKeeper.new hashcodefile
    keeper.save "hck_test.txt"
    assert_equal hashcodefile, IO.readlines("hck_test.txt").to_s
  end

  def test_should_add_codes_to_new_content_when_saving
    @keeper.save "hck_test.txt"
    assert_equal "]C[GI_URTE\n()FIKK-INGEFÆR\n-1954996374\n\n", IO.readlines("hck_test.txt").to_s
  end

  def hashcodefile
    <<-FILE
]C[KRAV
content1
123
content2
456,789

]C[VRAK
content3
987,654,321

FILE
  end

  def test_should_get_first_code_for_var_content_combo
    assert_equal -1954996374, @keeper.code_for("GI_URTE", "()FIKK-INGEFÆR")
  end

  def test_should_avoid_duplicates
    @keeper.add("GI_URTE", "()FIKK-INGEFÆR")
    assert_equal 1, @keeper.contentlist_for("GI_URTE").size
  end

  def test_should_keep_codes_for_var
    contentlist = @keeper.contentlist_for("GI_URTE")
    assert_equal 1, contentlist.size
    content = contentlist.first
    assert_equal "()FIKK-INGEFÆR", content.text
    assert_equal [-1954996374], content.codes
  end

  def test_should_keep_variables_separated
    @keeper.add("GI_URTE", "$URTE:BEKMYRT++")
    @keeper.add("GI_URTE_HOPP", "@1234")
    contentlist = @keeper.contentlist_for("GI_URTE")
    assert_equal 2, contentlist.size
    content = contentlist.first
    assert_equal "()FIKK-INGEFÆR", content.text
    assert_equal [-1954996374], content.codes
    content = contentlist.last
    assert_equal "$URTE:BEKMYRT++", content.text
    assert_equal [-2109176345], content.codes
  end

end
