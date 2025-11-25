# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApprovalPolicy do
  let(:pl_user) { create(:user) }
  let(:kp_user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:group) { create(:group, user: kp_user) }
  let(:pending_event) { create(:pending_event, group: group) }
  let(:approval) { create(:approval, pending_event: pending_event, user: pl_user) }

  before do
    group.memberships.create!(user: pl_user, role: :pl)
    group.memberships.create!(user: kp_user, role: :kp)
  end

  context '#create?' do
    it 'PLがcreateアクセスを許可される' do
      policy = ApprovalPolicy.new(pl_user, approval)
      expect(policy.create?).to be true
    end

    it 'KPはcreateアクセスを拒否される' do
      policy = ApprovalPolicy.new(kp_user, approval)
      expect(policy.create?).to be false
    end

    it 'メンバーではないユーザーはcreateアクセスを拒否される' do
      policy = ApprovalPolicy.new(other_user, approval)
      expect(policy.create?).to be false
    end
  end

  context '#update?' do
    it 'PLがupdateアクセスを許可される' do
      policy = ApprovalPolicy.new(pl_user, approval)
      expect(policy.update?).to be true
    end

    it 'KPはupdateアクセスを拒否される' do
      policy = ApprovalPolicy.new(kp_user, approval)
      expect(policy.update?).to be false
    end

    it 'メンバーではないユーザーはupdateアクセスを拒否される' do
      policy = ApprovalPolicy.new(other_user, approval)
      expect(policy.update?).to be false
    end
  end
end
