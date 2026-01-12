require 'test_helper'

class UsersIndexTest < ActionDispatch::IntegrationTest

  def setup
    @admin     = users(:michael)
    @non_admin = users(:archer)
  end

  test "index as admin including pagination and delete links" do
    log_in_as(@admin)
    get users_path
    assert_template 'users/index'
    assert_select 'div.pagination'
    first_page_of_users = User.where(activated: true).paginate(page: 1)
    first_page_of_users.each do |user|
      assert_select 'a[href=?]', user_path(user), text: user.name
      unless user == @admin
        assert_select 'a[href=?]', user_path(user), text: 'delete'
      end
    end
    assert_difference 'User.count', -1 do
      delete user_path(@non_admin)
    end
  end

  test "index as non-admin" do
    log_in_as(@non_admin)
    get users_path
    assert_select 'a', text: 'delete', count: 0
  end
  
  test "should not allow non-admin to delete users" do
    log_in_as(@non_admin)
    assert_no_difference 'User.count' do
      delete user_path(@admin)
    end
    assert_redirected_to root_url
  end
  
  test "index should only show activated users" do
    log_in_as(@admin)
    # 有効化されていないユーザーを作成
    unactivated_user = User.create!(name: "Unactivated User",
                                    email: "unactivated@example.com",
                                    password: "password",
                                    password_confirmation: "password",
                                    activated: false)
    
    get users_path
    assert_template 'users/index'
    # 有効化されたユーザーは表示される
    assert_select 'a[href=?]', user_path(@admin), text: @admin.name
    assert_select 'a[href=?]', user_path(@non_admin), text: @non_admin.name
    # 有効化されていないユーザーは表示されない
    assert_select 'a[href=?]', user_path(unactivated_user), count: 0
  end
  
  test "should redirect show page for unactivated user" do
    log_in_as(@admin)
    # 有効化されていないユーザーを作成
    unactivated_user = User.create!(name: "Unactivated User",
                                    email: "unactivated@example.com",
                                    password: "password",
                                    password_confirmation: "password",
                                    activated: false)
    
    get user_path(unactivated_user)
    assert_redirected_to root_url
  end
  
  test "should show activated user profile page" do
    log_in_as(@admin)
    get user_path(@non_admin)
    assert_template 'users/show'
    assert_select 'h1', text: @non_admin.name
  end
end
