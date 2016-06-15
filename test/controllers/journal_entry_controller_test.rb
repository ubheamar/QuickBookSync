require 'test_helper'

class JournalEntryControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

end
