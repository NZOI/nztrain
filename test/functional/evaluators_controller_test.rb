require 'test_helper'

class EvaluatorsControllerTest < ActionController::TestCase
  setup do
    @evaluator = evaluators(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:evaluators)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create evaluator" do
    assert_difference('Evaluator.count') do
      post :create, :evaluator => @evaluator.attributes
    end

    assert_redirected_to evaluator_path(assigns(:evaluator))
  end

  test "should show evaluator" do
    get :show, :id => @evaluator.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @evaluator.to_param
    assert_response :success
  end

  test "should update evaluator" do
    put :update, :id => @evaluator.to_param, :evaluator => @evaluator.attributes
    assert_redirected_to evaluator_path(assigns(:evaluator))
  end

  test "should destroy evaluator" do
    assert_difference('Evaluator.count', -1) do
      delete :destroy, :id => @evaluator.to_param
    end

    assert_redirected_to evaluators_path
  end
end
