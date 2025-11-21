class GroupsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_group, only: [:show, :edit, :update, :destroy, :add_member, :remove_member]
  before_action :authorize_group, only: [:show, :edit, :update, :destroy]

  def index
    @groups = policy_scope(Group)
  end

  def show
    # neko_gemを使用してカレンダーを生成
    require 'neko_gem'
    today = Time.zone.today
    @calendar = NekoGem::Calendar.new(today.year, today.month).generate
  end

  def new
    @group = Group.new
    authorize @group
  end

  def create
    @group = Group.new(group_params)
    authorize @group

    if @group.save
      # Create KP membership for the current user
      @group.memberships.create!(user: current_user, role: :kp)
      redirect_to @group, notice: t('groups.create.success')
    else
      render :new, status: :unprocessable_entity, alert: t('groups.create.failed')
    end
  end

  def edit
  end

  def update
    if @group.update(group_params)
      redirect_to @group, notice: t('groups.update.success')
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @group.destroy
    redirect_to groups_path, notice: 'Group was successfully destroyed.'
  end

  def add_member
    authorize @group, :add_member?

    user = User.find_by(email: params[:email])
    return redirect_to @group, alert: t('groups.add_member.user_not_found') if user.nil?
    return redirect_to @group, alert: t('groups.add_member.already_member') if @group.members.include?(user)

    @group.memberships.create!(user: user, role: :pl)
    redirect_to @group, notice: t('groups.add_member.success')
  rescue ActiveRecord::RecordInvalid => e
    redirect_to @group, alert: t('groups.add_member.failed', message: e.message)
  end

  def remove_member
    authorize @group, :remove_member?

    membership = @group.memberships.find_by(user_id: params[:user_id])
    return redirect_to @group, alert: t('groups.remove_member.not_found') if membership.nil?
    return redirect_to @group, alert: t('groups.remove_member.cannot_remove_kp') if membership.kp?

    membership.destroy
    redirect_to @group, notice: t('groups.remove_member.success')
  end

  def leave_group
    @group = Group.find(params[:id])
    membership = @group.memberships.find_by(user_id: current_user.id)

    return redirect_to groups_path, alert: t('groups.leave_group.not_member') if membership.nil?
    return redirect_to @group, alert: t('groups.leave_group.kp_cannot_leave') if membership.kp?

    membership.destroy
    redirect_to groups_path, notice: t('groups.leave_group.success')
  end

  private

  def set_group
    @group = Group.find(params[:id])
  end

  def authorize_group
    authorize @group
  end

  def group_params
    params.require(:group).permit(:name, :intro, :planned_period_start, :planned_period_end)
  end
end
