require 'test/unit'
require 'rubygems'
require 'mocha'
require 'changes_only_compiler'

class ChangesOnlyCompilerTestCase < Test::Unit::TestCase

  def setup
    @compiler = ChangesOnlyCompiler.new "../../../eventyr/master"
  end
  
  def test_should_know_target_directory
    assert_equal("../compiled_pages/master", @compiler.target_directory)
  end

  def test_should_compile_nothing_for_no_changes
    setup_change_tracker([])
    assert_equal([], @compiler.affected_rooms)
  end

  def test_should_find_affected_rooms
    setup_change_tracker([1])
    assert_equal([9, 8, 1], @compiler.affected_rooms)
  end
  
  def test_should_remove_duplicates
    setup_change_tracker([1, 8])
    assert_equal([9, 8, 1], @compiler.affected_rooms)
  end

  def test_should_create_pages
    setup_change_tracker([9])
    setup_temporary_target
    Page.expects(:new).returns(room_mock(9))
    @compiler.compile!
    assert File.exists?("temporary_target_folder/9/9.php"), "No master-copy created"
    assert File.exists?("temporary_target_folder/versions/9/9_123.php"), "No versions-copy created"
    assert_equal(["<code>\n"], IO.readlines("temporary_target_folder/9/9.php"))
    assert_equal(["<code>\n"], IO.readlines("temporary_target_folder/versions/9/9_123.php"))
    `rm -rf temporary_target_folder`
  end

  def test_should_include_files_to_always_compile
    @compiler = ChangesOnlyCompiler.new "/", [4165]
    setup_change_tracker([1])
    assert_equal([4165, 9, 8, 1], @compiler.affected_rooms)
  end

  def test_should_save_current_state
    setup_change_tracker([])
    @compiler.change_tracker.expects(:save_current_state!)
    @compiler.compile!
  end

  private
  
  def setup_change_tracker(rooms)
    @compiler.target_directory = File.dirname(__FILE__) + "/compiler_test_files"
    @compiler.change_tracker = mock('change_tracker')
    @compiler.change_tracker.stubs(:changed_rooms).returns(rooms)
    @compiler.change_tracker.stubs(:save_current_state!)
  end

  def setup_temporary_target
    `rm -rf temporary_target_folder`
    `cp -R #{File.dirname(__FILE__)}/compiler_test_files temporary_target_folder`
    @compiler.target_directory = "temporary_target_folder"
  end

  def room_mock(number)
    @compiler.room_loader.stubs(:room_exists?).returns(true)
    room = mock('room')
    room.stubs(:code).returns("<code>")
    room.stubs(:identifier).returns("#{number}_123")
    room
  end

end