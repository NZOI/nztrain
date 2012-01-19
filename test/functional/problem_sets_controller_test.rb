require 'test_helper'

class ProblemSetsControllerTest < ActionController::TestCase
  setup do
    @problem_set = problem_sets(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:problem_sets)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create problem_set" do
    assert_difference('ProblemSet.count') do
      post :create, :problem_set => @problem_set.attributes
    end

    assert_redirected_to problem_set_path(assigns(:problem_set))
  end

  test "should show problem_set" do
    get :show, :id => @problem_set.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @problem_set.to_param
    assert_response :success
  end

  test "should update problem_set" do
    put :update, :id => @problem_set.to_param, :problem_set => @problem_set.attributes
    assert_redirected_to problem_set_path(assigns(:problem_set))
  end

  test "should destroy problem_set" do
    assert_difference('ProblemSet.count', -1) do
      delete :destroy, :id => @problem_set.to_param
    end

    assert_redirected_to problem_sets_path
  end
end
