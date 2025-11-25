# frozen_string_literal: true

class ConfirmedEventPolicy < ApplicationPolicy
  def show?
    user_is_group_member?
  end

  def destroy?
    user_is_group_kp?
  end

  private

  def user_is_group_member?
    record.group.members.include?(user)
  end

  def user_is_group_kp?
    membership = record.group.memberships.find_by(user_id: user.id)
    membership&.kp? || false
  end
end
