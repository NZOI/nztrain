require 'test_helper'

class ContestRelationsControllerTest < ActionController::TestCase
  setup do
    @contest_relation = contest_relations(:one)
  end
# No direct changes
#  test "should get index" do
#    get :index
#    assert_response :success
#    assert_not_nil assigns(:contest_relations)
#  end
#
#  test "should get new" do
#    get :new
#    assert_response :success
#  end
#
#  test "should create contest_relation" do
#    assert_difference('ContestRelation.count') do
#      post :create, :contest_relation => @contest_relation.attributes
#    end
#
#    assert_redirected_to contest_relation_path(assigns(:contest_relation))
#  end
#
#  test "should show contest_relation" do
#    get :show, :id => @contest_relation.to_param
#    assert_response :success
#  end
#
#  test "should get edit" do
#    get :edit, :id => @contest_relation.to_param
#    assert_response :success
#  end
#
#  test "should update contest_relation" do
#    put :update, :id => @contest_relation.to_param, :contest_relation => @contest_relation.attributes
#    assert_redirected_to contest_relation_path(assigns(:contest_relation))
#  end
#
#  test "should destroy contest_relation" do
#    assert_difference('ContestRelation.count', -1) do
#      delete :destroy, :id => @contest_relation.to_param
#    end
#
#    assert_redirected_to contest_relations_path
#  end
end
