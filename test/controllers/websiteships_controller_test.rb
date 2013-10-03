require 'test_helper'

class WebsiteshipsControllerTest < ActionController::TestCase
  setup do
    @websiteship = websiteships(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:websiteships)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create websiteship" do
    assert_difference('Websiteship.count') do
      post :create, websiteship: { user_id: @websiteship.user_id, website_id: @websiteship.website_id }
    end

    assert_redirected_to websiteship_path(assigns(:websiteship))
  end

  test "should show websiteship" do
    get :show, id: @websiteship
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @websiteship
    assert_response :success
  end

  test "should update websiteship" do
    patch :update, id: @websiteship, websiteship: { user_id: @websiteship.user_id, website_id: @websiteship.website_id }
    assert_redirected_to websiteship_path(assigns(:websiteship))
  end

  test "should destroy websiteship" do
    assert_difference('Websiteship.count', -1) do
      delete :destroy, id: @websiteship
    end

    assert_redirected_to websiteships_path
  end
end
