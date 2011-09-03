require 'test_helper'

class ProblemsControllerTest < ActionController::TestCase
  setup do
    @problem = problems(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:problems)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create problem" do
    assert_difference('Problem.count') do
      post :create, :problem => @problem.attributes
    end

    assert_redirected_to problem_path(assigns(:problem))
  end

  test "should show problem" do
    get :show, :id => @problem.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @problem.to_param
    assert_response :success
  end

  test "should update problem" do
    put :update, :id => @problem.to_param, :problem => @problem.attributes
    assert_redirected_to problem_path(assigns(:problem))
  end

  test "should destroy problem" do
    assert_difference('Problem.count', -1) do
      delete :destroy, :id => @problem.to_param
    end

    assert_redirected_to problems_path
  end
end
