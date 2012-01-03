require 'test_helper'

class ActionSmser::DeliveryReportsControllerTest < ActionController::TestCase
  test "index should be ok" do
    get :index, {:use_route => :action_smser}
    assert_response :success
  end
  

end


#module ActionSmser
#  class DeliveryReportsControllerTest < ActionController::TestCase
#    setup do
#      @delivery_report = delivery_reports(:one)
#    end
#
#    test "should get index" do
#      get :index
#      assert_response :success
#      assert_not_nil assigns(:delivery_reports)
#    end
#
#    test "should get new" do
#      get :new
#      assert_response :success
#    end
#
#    test "should create delivery_report" do
#      assert_difference('DeliveryReport.count') do
#        post :create, :delivery_report => @delivery_report.attributes
#      end
#
#      assert_redirected_to delivery_report_path(assigns(:delivery_report))
#    end
#
#    test "should show delivery_report" do
#      get :show, :id => @delivery_report.to_param
#      assert_response :success
#    end
#
#    test "should get edit" do
#      get :edit, :id => @delivery_report.to_param
#      assert_response :success
#    end
#
#    test "should update delivery_report" do
#      put :update, :id => @delivery_report.to_param, :delivery_report => @delivery_report.attributes
#      assert_redirected_to delivery_report_path(assigns(:delivery_report))
#    end
#
#    test "should destroy delivery_report" do
#      assert_difference('DeliveryReport.count', -1) do
#        delete :destroy, :id => @delivery_report.to_param
#      end
#
#      assert_redirected_to delivery_reports_path
#    end
#  end
#end
