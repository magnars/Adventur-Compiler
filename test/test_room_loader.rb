require 'test/unit'
require 'rubygems'
require 'mocha'
require 'room_loader'

class RoomLoaderTestCase < Test::Unit::TestCase

  def setup
    @folder = "testrooms"
    @subfolder = "#{@folder}/A00"
    @roomfile = "#{@subfolder}/A0.adv"
    teardown

    Dir.mkdir(@folder)
    Dir.mkdir(@subfolder)
    File.open(@roomfile, 'w') { |file| file.print "Line 1 of room #0\n Line 2 of room #0  \n" }

    @loader = RoomLoader.new @folder
  end

  def teardown
    File.delete(@roomfile) if File.exists? @roomfile
    Dir.rmdir(@subfolder) if File.exists? @subfolder
    Dir.rmdir(@folder) if File.exists? @folder
  end

  def test_should_know_if_a_room_exists
    assert(@loader.room_exists?(0), "Room 0 should exist")
    assert( ! @loader.room_exists?(17), "Room 17 should not exist")
  end

  def test_should_always_keep_last_loaded_room_number
    assert_equal("none", RoomLoader.last_loaded_room_number)
    @loader.get(0)
    assert_equal(0, RoomLoader.last_loaded_room_number)
  end

  def test_should_extend_with_room_module
    assert_kind_of(Room, @loader.get(0))
  end

  def test_should_insert_room_number
    assert_equal(0, @loader.get(0).number)
  end

  def test_should_list_all_room_numbers
    assert_equal([0], @loader.all_room_numbers)
  end

  def test_should_load_rooms_from_given_source
    assert_equal(['Line 1 of room #0', 'Line 2 of room #0'], @loader.get(0))
  end

end
