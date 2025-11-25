# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PendingEventPolicy do
  let(:kp_user) { create(:user) }
  let(:pl_user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:group) { create(:group, user: kp_user) }
  let(:pending_event) { create(:pending_event, group: group) }

  before do
    group.memberships.create!(user: pl_user, role: :pl)
    group.memberships.create!(user: kp_user, role: :kp)
  end

  context '#show?' do
    it 'メンバーがshowアクセスを許可される' do
      policy = PendingEventPolicy.new(pl_user, pending_event)
      expect(policy.show?).to be true
    end

    it 'メンバーではないユーザーはshowアクセスを拒否される' do
      policy = PendingEventPolicy.new(other_user, pending_event)
      expect(policy.show?).to be false
    end
  end

  context '#create?' do
    it 'KPがcreateアクセスを許可される' do
      policy = PendingEventPolicy.new(kp_user, pending_event)
      expect(policy.create?).to be true
    end

    it 'PLはcreateアクセスを拒否される' do
      policy = PendingEventPolicy.new(pl_user, pending_event)
      expect(policy.create?).to be false
    end

    it 'メンバーではないユーザーはcreateアクセスを拒否される' do
      policy = PendingEventPolicy.new(other_user, pending_event)
      expect(policy.create?).to be false
    end
  end

  context '#destroy?' do
    it 'KPがdestroyアクセスを許可される' do
      policy = PendingEventPolicy.new(kp_user, pending_event)
      expect(policy.destroy?).to be true
    end

    it 'PLはdestroyアクセスを拒否される' do
      policy = PendingEventPolicy.new(pl_user, pending_event)
      expect(policy.destroy?).to be false
    end

    it 'メンバーではないユーザーはdestroyアクセスを拒否される' do
      policy = PendingEventPolicy.new(other_user, pending_event)
      expect(policy.destroy?).to be false
    end
  end
end
