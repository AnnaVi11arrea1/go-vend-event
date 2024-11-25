# == Schema Information
#
# Table name: follow_requests
#
#  id           :bigint           not null, primary key
#  status       :string           default("pending")
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  recipient_id :bigint           not null
#  sender_id    :bigint           not null
#
# Indexes
#
#  index_follow_requests_on_recipient_id  (recipient_id)
#  index_follow_requests_on_sender_id     (sender_id)
#
# Foreign Keys
#
#  fk_rails_...  (recipient_id => users.id)
#  fk_rails_...  (sender_id => users.id)
#
class FollowRequest < ApplicationRecord
  belongs_to :recipient, class_name: 'User' 
  belongs_to :sender, class_name: 'User'

  enum status: { pending: "pending", rejected: "rejected", accepted: "accepted"}

  validates :recipient_id, uniqueness: { scope: :sender_id, message: "already requested" }

  validate :users_cant_follow_themselves

  def users_cant_follow_themselves
    if sender_id == recipient_id
      errors.add(:sender_id, "can't follow themselves")
    end
  end
end
