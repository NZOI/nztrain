require 'test_helper'

class GroupsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  setup do
    sign_in users(:adminuser)
    @group = groups(:group)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:groups)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create group" do
    assert_difference('Group.count') do
      post :create, :group => {:name => "My new unique group"}
    end

    assert_redirected_to group_path(assigns(:group))
  end

  test "should show group" do
    get :show, :id => @group.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @group.to_param
    assert_response :success
  end

  test "should update group" do
    put :update, :id => @group.to_param, :group => @group.attributes
    assert_redirected_to group_path(assigns(:group))
  end

  test "should destroy group" do
    assert_difference('Group.count', -1) do
      delete :destroy, :id => @group.to_param
    end

    assert_redirected_to groups_path
  end
end
