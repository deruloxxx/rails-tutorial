require 'test_helper'

class UsersEditTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
  end

  test "unsuccessful edit" do
    log_in_as(@user)
    get edit_user_path(@user)
    assert_template 'users/edit'
    patch user_path(@user), params: { user: { name:  "",
                                              email: "foo@invalid",
                                              password:              "foo",
                                              password_confirmation: "bar" } }

    assert_template 'users/edit'
  end
  
  test "successful edit" do
    log_in_as(@user)
    get edit_user_path(@user)
    assert_template 'users/edit'
    name  = "Foo Bar"
    email = "foo@bar.com"
    patch user_path(@user), params: { user: { name:  name,
                                              email: email,
                                              password:              "",
                                              password_confirmation: "" } }
    assert_not flash.empty?
    assert_redirected_to @user
    @user.reload
    assert_equal name,  @user.name
    assert_equal email, @user.email
  end
  
  test "successful edit with friendly forwarding" do
    get edit_user_path(@user)
    log_in_as(@user)
    assert_redirected_to edit_user_url(@user)
    name  = "Foo Bar"
    email = "foo@bar.com"
    patch user_path(@user), params: { user: { name:  name,
                                              email: email,
                                              password:              "",
                                              password_confirmation: "" } }
    assert_not flash.empty?
    assert_redirected_to @user
    @user.reload
    assert_equal name,  @user.name
    assert_equal email, @user.email
  end
  
  test "friendly forwarding only forwards on first login" do
    # 初回: 保護されたページにアクセス
    get edit_user_path(@user)
    # session[:forwarding_url]が正しく設定されているか確認
    assert_equal edit_user_url(@user), session[:forwarding_url]
    
    # ログイン → 保護されたページにリダイレクト
    log_in_as(@user)
    assert_redirected_to edit_user_url(@user)
    # redirect_back_or内でsession[:forwarding_url]は削除されている
    # リダイレクトを追跡
    follow_redirect!
    assert_template 'users/edit'
    # リダイレクト後、session[:forwarding_url]は削除されている
    assert_nil session[:forwarding_url]
    
    # ログアウト
    delete logout_path
    follow_redirect!
    
    # 次回: 再度ログイン（保護されたページにアクセスせずに）
    log_in_as(@user)
    # デフォルト（プロフィール画面）にリダイレクトされる
    assert_redirected_to @user
    # session[:forwarding_url]は設定されていない（保護されたページにアクセスしていないため）
    assert_nil session[:forwarding_url]
  end
end
