require 'test_helper'

class InvitationRequestsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:invitation_requests)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create invitation_request" do
    assert_difference('InvitationRequest.count') do
      post :create, :invitation_request => { }
    end

    assert_redirected_to invitation_request_path(assigns(:invitation_request))
  end

  test "should show invitation_request" do
    get :show, :id => invitation_requests(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => invitation_requests(:one).to_param
    assert_response :success
  end

  test "should update invitation_request" do
    put :update, :id => invitation_requests(:one).to_param, :invitation_request => { }
    assert_redirected_to invitation_request_path(assigns(:invitation_request))
  end

  test "should destroy invitation_request" do
    assert_difference('InvitationRequest.count', -1) do
      delete :destroy, :id => invitation_requests(:one).to_param
    end

    assert_redirected_to invitation_requests_path
  end
end