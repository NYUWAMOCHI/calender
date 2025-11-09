class GroupsController < ApplicationController
  before_action :authenticate_user!

  def show
    @group = Group.find(params[:id])

    # neko_gemを使用してカレンダーを生成
    require 'neko_gem'
    today = Date.today
    @calendar = NekoGem::Calendar.new(today.year, today.month).generate
  end
end
