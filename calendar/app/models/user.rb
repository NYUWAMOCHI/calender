class User < ApplicationRecord
  has_many :memberships, dependent: :destroy
  has_many :groups, through: :memberships

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # バリデーション
  validates :name, presence: true, length: { maximum: 20 }
  validates :email, presence: true, uniqueness: true,
            format: { with: /\A[a-zA-Z0-9_+-]+(\.[a-zA-Z0-9_+-]+)*@([a-zA-Z0-9][a-zA-Z0-9-]*[a-zA-Z0-9]*\.)+[a-zA-Z]{2,}\z/ }
  validates :google_uid, uniqueness: true, allow_nil: true

  # パスワードのバリデーションはDeviseの標準設定を使用
  # minimum: 6文字はDeviseのデフォルト設定
end
