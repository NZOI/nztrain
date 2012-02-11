require 'test_helper'

class TestSetsControllerTest < ActionController::TestCase
  setup do
    @test_set = test_sets(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:test_sets)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create test_set" do
    assert_difference('TestSet.count') do
      post :create, :test_set => @test_set.attributes
    end

    assert_redirected_to test_set_path(assigns(:test_set))
  end

  test "should show test_set" do
    get :show, :id => @test_set.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @test_set.to_param
    assert_response :success
  end

  test "should update test_set" do
    put :update, :id => @test_set.to_param, :test_set => @test_set.attributes
    assert_redirected_to test_set_path(assigns(:test_set))
  end

  test "should destroy test_set" do
    assert_difference('TestSet.count', -1) do
      delete :destroy, :id => @test_set.to_param
    end

    assert_redirected_to test_sets_path
  end
end
