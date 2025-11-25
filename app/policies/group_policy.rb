# frozen_string_literal: true

class GroupPolicy < ApplicationPolicy
  def index?
    user.present?
  end

  def show?
    user_is_member?
  end

  def create?
    user.present?
  end

  def update?
    user_is_kp?
  end

  def destroy?
    user_is_kp?
  end

  def add_member?
    user_is_kp?
  end

  def remove_member?
    user_is_kp?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.joins(:memberships).where(memberships: { user_id: user.id }).distinct
    end
  end

  private

  def user_is_member?
    record.members.include?(user)
  end

  def user_is_kp?
    membership = record.memberships.find_by(user_id: user.id)
    membership&.kp? || false
  end
end
