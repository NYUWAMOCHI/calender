# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  # 新規登録後のリダイレクト先をカスタマイズ
  def after_sign_up_path_for(resource)
    dashboard_path
  end

  # アカウント更新後のリダイレクト先をカスタマイズ
  def after_update_path_for(resource)
    dashboard_path
  end

  protected

  # アカウント更新時にパスワードを要求しない
  def update_resource(resource, params)
    if params[:password].blank?
      resource.update_without_password(params)
    else
      resource.update_with_password(params)
    end
  end
end
