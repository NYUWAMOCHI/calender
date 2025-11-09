# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  # ログイン後のリダイレクト先をカスタマイズ
  def after_sign_in_path_for(_resource)
    dashboard_path
  end

  # ログアウト後のリダイレクト先をカスタマイズ
  def after_sign_out_path_for(_resource_or_scope)
    root_path
  end
end
