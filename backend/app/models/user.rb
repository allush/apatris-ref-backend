# == Schema Information
#
# Table name: users
#
#  id          :bigint           not null, primary key
#  address     :string           not null
#  invite_code :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  inviter_id  :bigint
#
# Indexes
#
#  index_users_on_inviter_id  (inviter_id)
#
class User < ApplicationRecord
  validates :address, uniqueness: true, length: { is: 42 }
  validate :validate_address

  belongs_to :inviter, class_name: 'User', optional: true
  has_many :partners, class_name: 'User', foreign_key: :inviter_id

  def create_invite_code!
    return invite_code if invite_code

    code = (id + 5_000_000).to_s(32)
    update!(invite_code: code)
  end

  private

  def validate_address
    errors.add(:address, :invalid) unless Eth::Utils.valid_address?(address)
  end
end
