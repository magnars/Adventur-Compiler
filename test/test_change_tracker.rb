require 'test/unit'
require 'rubygems'
require 'mocha'
require 'change_tracker'

class ChangeTrackerTestCase < Test::Unit::TestCase

  def setup
    @testfiles = "#{File.dirname(__FILE__)}/compiler_test_files"
    @temporary = "#{File.dirname(__FILE__)}/temporary_directory"
    teardown
    Dir.mkdir @temporary
  end
  
  def teardown
    `rm -rf #{@temporary}`
  end

  def test_should_find_changed_rooms
    tracker = ChangeTracker.new @testfiles, @testfiles
    assert_equal([12503, 12504], tracker.changed_rooms)
  end

  def test_should_find_all_rooms_if_last_compile_file_is_missing
    tracker = ChangeTracker.new @testfiles, @temporary
    assert_equal([12501, 12502, 12503, 12504], tracker.changed_rooms)
  end

  def test_should_save_current_state
    tracker = ChangeTracker.new @temporary, @temporary
    tracker.save_current_state!
    assert File.exists?("#{@temporary}/last_compile.txt"), "Room-state file not created"
  end

end