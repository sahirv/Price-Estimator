require 'test_helper'

class MatchtestsControllerTest < ActionController::TestCase
  setup do
    @matchtest = matchtests(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:matchtests)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create matchtest" do
    assert_difference('Matchtest.count') do
      post :create, matchtest: {  }
    end

    assert_redirected_to matchtest_path(assigns(:matchtest))
  end

  test "should show matchtest" do
    get :show, id: @matchtest
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @matchtest
    assert_response :success
  end

  test "should update matchtest" do
    patch :update, id: @matchtest, matchtest: {  }
    assert_redirected_to matchtest_path(assigns(:matchtest))
  end

  test "should destroy matchtest" do
    assert_difference('Matchtest.count', -1) do
      delete :destroy, id: @matchtest
    end

    assert_redirected_to matchtests_path
  end
end
