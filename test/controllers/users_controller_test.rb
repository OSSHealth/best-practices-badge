# frozen_string_literal: true

# Copyright 2015-2017, the Linux Foundation, IDA, and the
# CII Best Practices badge contributors
# SPDX-License-Identifier: MIT

require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  setup do
    @user = users(:test_user_melissa)
    @other_user = users(:test_user_mark)
    @admin = users(:admin_user)
  end

  test 'should get index' do
    log_in_as(@admin)
    get :index
    assert_response :success
    assert_not_nil assigns(:users)
  end

  test 'should get new' do
    get :new
    assert_response :success
  end

  test 'should redirect edit when not logged in' do
    get :edit, params: { id: @user }
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test 'should redirect update when not logged in' do
    patch :update, params: {
      id: @user, user: { name: @user.name, email: @user.email }
    }
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test 'should redirect edit when logged in as wrong user' do
    log_in_as(@other_user)
    get :edit, params: { id: @user }
    assert flash.empty?
    assert_redirected_to root_url
  end

  test 'should redirect update when logged in as wrong user' do
    log_in_as(@other_user)
    patch :update, params: {
      id: @user, user: { name: @user.name, email: @user.email }
    }
    assert flash.empty?
    assert_redirected_to root_url
  end

  test 'should  update user when logged in as admin' do
    new_name = @user.name + '_updated'
    log_in_as(@admin)
    patch :update, params: { id: @user, user: { name: new_name } }
    assert_not_empty flash
    @user.reload
    assert_equal @user.name, new_name
  end

  test 'should be able to change locale' do
    log_in_as(@user)
    patch :update, params: { id: @user, user: { preferred_locale: 'fr' } }
    assert_not_empty flash # Success message
    @user.reload
    assert_equal 'fr', @user.preferred_locale
    assert_redirected_to users_path(locale: 'fr') + "/#{@user.id}"
  end

  test 'should redirect destroy when not logged in' do
    assert_no_difference 'User.count' do
      delete :destroy, params: { id: @user }
    end
    assert_redirected_to root_url
  end

  test 'should redirect destroy when logged in as a non-admin' do
    log_in_as(@other_user)
    assert_no_difference 'User.count' do
      delete :destroy, params: { id: @user }
    end
    assert_redirected_to root_url
  end

  test 'should destroy user when logged in as admin' do
    log_in_as(@admin)
    assert_difference('User.count', -1) do
      delete :destroy, params: { id: @other_user }
    end
    assert_not_empty flash
  end

  test 'should not be able to destroy self' do
    log_in_as(@admin)
    assert_no_difference 'User.count' do
      delete :destroy, params: { id: @admin }
    end
    assert_not_empty flash
  end
end
