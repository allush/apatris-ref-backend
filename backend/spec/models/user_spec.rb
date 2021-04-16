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
require 'rails_helper'

RSpec.describe User, type: :model do
  describe '#create_invite_code!' do
    let!(:instance) { create :user, id: 1 }
    subject { instance.create_invite_code! }
    it {
      expect { subject }
        .to change { instance.invite_code }
        .from(nil)
        .to('4oiq1')
    }
  end
end
