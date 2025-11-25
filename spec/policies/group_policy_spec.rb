# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GroupPolicy do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:group) { create(:group, user: user) }
  let(:other_group) { create(:group, user: other_user) }

  context '#index?' do
    it 'ユーザーが認証されていればindexアクセスを許可する' do
      policy = GroupPolicy.new(user, Group)
      expect(policy.index?).to be true
    end

    it 'ユーザーが認証されていなければindexアクセスを拒否する' do
      policy = GroupPolicy.new(nil, Group)
      expect(policy.index?).to be false
    end
  end

  context '#create?' do
    it 'ユーザーが認証されていればcreateアクセスを許可する' do
      policy = GroupPolicy.new(user, Group.new)
      expect(policy.create?).to be true
    end

    it 'ユーザーが認証されていなければcreateアクセスを拒否する' do
      policy = GroupPolicy.new(nil, Group.new)
      expect(policy.create?).to be false
    end
  end

  context '#show?' do
    it 'メンバーがshowアクセスを許可される' do
      group.memberships.create!(user: user, role: :pl)
      policy = GroupPolicy.new(user, group)
      expect(policy.show?).to be true
    end

    it 'メンバーではないユーザーはshowアクセスを拒否される' do
      policy = GroupPolicy.new(other_user, group)
      expect(policy.show?).to be false
    end
  end

  context '#update?' do
    it 'KPがupdateアクセスを許可される' do
      group.memberships.create!(user: user, role: :kp)
      policy = GroupPolicy.new(user, group)
      expect(policy.update?).to be true
    end

    it 'PLはupdateアクセスを拒否される' do
      group.memberships.create!(user: user, role: :pl)
      policy = GroupPolicy.new(user, group)
      expect(policy.update?).to be false
    end

    it 'メンバーではないユーザーはupdateアクセスを拒否される' do
      policy = GroupPolicy.new(other_user, group)
      expect(policy.update?).to be false
    end
  end

  context '#destroy?' do
    it 'KPがdestroyアクセスを許可される' do
      group.memberships.create!(user: user, role: :kp)
      policy = GroupPolicy.new(user, group)
      expect(policy.destroy?).to be true
    end

    it 'PLはdestroyアクセスを拒否される' do
      group.memberships.create!(user: user, role: :pl)
      policy = GroupPolicy.new(user, group)
      expect(policy.destroy?).to be false
    end

    it 'メンバーではないユーザーはdestroyアクセスを拒否される' do
      policy = GroupPolicy.new(other_user, group)
      expect(policy.destroy?).to be false
    end
  end

  context '#add_member?' do
    it 'KPがadd_memberアクセスを許可される' do
      group.memberships.create!(user: user, role: :kp)
      policy = GroupPolicy.new(user, group)
      expect(policy.add_member?).to be true
    end

    it 'PLはadd_memberアクセスを拒否される' do
      group.memberships.create!(user: user, role: :pl)
      policy = GroupPolicy.new(user, group)
      expect(policy.add_member?).to be false
    end

    it 'メンバーではないユーザーはadd_memberアクセスを拒否される' do
      policy = GroupPolicy.new(other_user, group)
      expect(policy.add_member?).to be false
    end
  end

  context '#remove_member?' do
    it 'KPがremove_memberアクセスを許可される' do
      group.memberships.create!(user: user, role: :kp)
      policy = GroupPolicy.new(user, group)
      expect(policy.remove_member?).to be true
    end

    it 'PLはremove_memberアクセスを拒否される' do
      group.memberships.create!(user: user, role: :pl)
      policy = GroupPolicy.new(user, group)
      expect(policy.remove_member?).to be false
    end

    it 'メンバーではないユーザーはremove_memberアクセスを拒否される' do
      policy = GroupPolicy.new(other_user, group)
      expect(policy.remove_member?).to be false
    end
  end

  describe 'Scope' do
    before do
      group.memberships.create!(user: user, role: :pl)
      other_group.memberships.create!(user: other_user, role: :pl)
    end

    it 'ユーザーはメンバーとなっているグループのみアクセスできる' do
      scope = Pundit.policy_scope!(user, Group)
      expect(scope).to include(group)
      expect(scope).not_to include(other_group)
    end
  end
end
