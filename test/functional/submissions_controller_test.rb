require 'test_helper'

class SubmissionsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  setup do
    sign_in users(:adminuser)
    @submission = submissions(:sub1)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:submissions)
  end

# Cannot create directly - to test submitting solution
#  test "should create submission" do
#    assert_difference('Submission.count') do
#      post :create, :submission => @submission.attributes
#    end
#
#    assert_redirected_to submission_path(assigns(:submission))
#  end
#
  test "should show submission" do
    get :show, :id => @submission.to_param
    assert_response :success
  end
# Should not need to edit?
#  test "should get edit" do
#    get :edit, :id => @submission.to_param
#    assert_response :success
#  end
# Should not need?
#  test "should update submission" do
#    put :update, :id => @submission.to_param, :submission => @submission.attributes
#    assert_redirected_to submission_path(assigns(:submission))
#  end

  test "should destroy submission" do
    assert_difference('Submission.count', -1) do
      delete :destroy, :id => @submission.to_param
    end

    assert_redirected_to submissions_path
  end
end
