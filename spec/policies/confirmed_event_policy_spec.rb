# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ConfirmedEventPolicy do
  let(:kp_user) { create(:user) }
  let(:pl_user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:group) { create(:group, user: kp_user) }
  let(:confirmed_event) { create(:confirmed_event, group: group) }

  before do
    group.memberships.create!(user: pl_user, role: :pl)
    group.memberships.create!(user: kp_user, role: :kp)
  end

  describe '#show?' do
    it 'メンバーがshowアクセスを許可される' do
      policy = described_class.new(pl_user, confirmed_event)
      expect(policy.show?).to be true
    end

    it 'メンバーではないユーザーはshowアクセスを拒否される' do
      policy = described_class.new(other_user, confirmed_event)
      expect(policy.show?).to be false
    end
  end

  describe '#destroy?' do
    it 'KPがdestroyアクセスを許可される' do
      policy = described_class.new(kp_user, confirmed_event)
      expect(policy.destroy?).to be true
    end

    it 'PLはdestroyアクセスを拒否される' do
      policy = described_class.new(pl_user, confirmed_event)
      expect(policy.destroy?).to be false
    end

    it 'メンバーではないユーザーはdestroyアクセスを拒否される' do
      policy = described_class.new(other_user, confirmed_event)
      expect(policy.destroy?).to be false
    end
  end
end
