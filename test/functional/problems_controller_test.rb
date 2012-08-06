require 'test_helper'

class ProblemsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  setup do
    sign_in users(:adminuser)
    @fakeproblem = problems(:fake)
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
      post :create, :problem => {:title => "New title", :statement => "Statement"}
    end

    assert_redirected_to problem_path(assigns(:problem))
  end

  test "should show problem" do
    get :show, :id => @fakeproblem.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @fakeproblem.to_param
    assert_response :success
  end

  test "should update problem" do
    put :update, :id => @fakeproblem.to_param, :problem => @fakeproblem.attributes
    assert_redirected_to problem_path(assigns(:problem))
  end

  test "should destroy problem" do
    assert_difference('Problem.count', -1) do
      delete :destroy, :id => @fakeproblem.to_param
    end

    assert_redirected_to problems_path
  end
end

