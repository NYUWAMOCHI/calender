class HomeController < ApplicationController
  def index
    if user_signed_in?
      redirect_to dashboard_path
    else
      # トップページの表示（ログイン前のランディングページ）
    end
  end
end
