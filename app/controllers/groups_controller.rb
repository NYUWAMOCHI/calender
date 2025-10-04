class GroupsController < ApplicationController
  before_action :authenticate_user!

  def create
    @group = current_user.groups.build(group_params)
    @group.owner_id = current_user.id.to_s

    if @group.save
      # ユーザーをグループのメンバーとして追加（作成者はKP）
      @group.memberships.create(user: current_user, role: :kp)

      redirect_to group_path(@group), notice: 'グループが作成されました'
    else
      redirect_to dashboard_path, alert: 'グループの作成に失敗しました'
    end
  end

  def show
    @group = Group.find(params[:id])
    @memberships = @group.memberships.includes(:user)
  end

  private

  def group_params
    params.require(:group).permit(:name, :intro)
  end
end
