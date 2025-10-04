class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    # ビューのみなので、データ取得は将来実装
  end
end
