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
FactoryBot.define do
  factory :user do
    address { '0x0000000000000000000000000000000000000000' }
    inviter_id { nil }
    invite_code { nil }
  end
end
