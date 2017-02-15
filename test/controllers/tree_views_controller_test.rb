require 'test_helper'

class TreeViewsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @tree_view = tree_views(:one)
  end

  test "should get index" do
    get tree_views_url
    assert_response :success
  end

  test "should get new" do
    get new_tree_view_url
    assert_response :success
  end

  test "should create tree_view" do
    assert_difference('TreeView.count') do
      post tree_views_url, params: { tree_view: { link: @tree_view.link } }
    end

    assert_redirected_to tree_view_url(TreeView.last)
  end

  test "should show tree_view" do
    get tree_view_url(@tree_view)
    assert_response :success
  end

  test "should get edit" do
    get edit_tree_view_url(@tree_view)
    assert_response :success
  end

  test "should update tree_view" do
    patch tree_view_url(@tree_view), params: { tree_view: { link: @tree_view.link } }
    assert_redirected_to tree_view_url(@tree_view)
  end

  test "should destroy tree_view" do
    assert_difference('TreeView.count', -1) do
      delete tree_view_url(@tree_view)
    end

    assert_redirected_to tree_views_url
  end
end
