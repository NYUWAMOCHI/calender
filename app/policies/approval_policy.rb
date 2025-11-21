# frozen_string_literal: true

class ApprovalPolicy < ApplicationPolicy
  def create?
    user_is_event_group_member? && user_is_pl?
  end

  def update?
    user_is_event_group_member? && user_is_pl?
  end

  private

  def user_is_event_group_member?
    record.pending_event.group.members.include?(user)
  end

  def user_is_pl?
    membership = record.pending_event.group.memberships.find_by(user_id: user.id)
    membership&.pl?
  end
end
