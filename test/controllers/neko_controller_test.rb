require "test_helper"

class NekoControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get neko_index_url
    assert_response :success
  end
end
