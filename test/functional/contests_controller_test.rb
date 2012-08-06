require 'test_helper'

class ContestsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  setup do
    sign_in users(:adminuser)
    @contest = contests(:badcontest)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:contests)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create contest" do
    assert_difference('Contest.count') do
      post :create, :contest => @contest.attributes.merge(:name => "Unique contest")
    end

    assert_redirected_to contest_path(assigns(:contest))
  end
## pending improvements - cached contest score
#  test "should show contest" do
#    get :show, :id => @contest.to_param
#    assert_response :success
#  end

  test "should get edit" do
    get :edit, :id => @contest.to_param
    assert_response :success
  end

  test "should update contest" do
    put :update, :id => @contest.to_param, :contest => @contest.attributes
    assert_redirected_to contest_path(assigns(:contest))
  end

  test "should destroy contest" do
    assert_difference('Contest.count', -1) do
      delete :destroy, :id => @contest.to_param
    end

    assert_redirected_to contests_path
  end
end
