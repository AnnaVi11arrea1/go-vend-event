# == Schema Information
#
# Table name: follow_requests
#
#  id           :integer          not null, primary key
#  status       :string           default("pending")
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  recipient_id :integer          not null
#  sender_id    :integer          not null
#
# Indexes
#
#  index_follow_requests_on_recipient_id  (recipient_id)
#  index_follow_requests_on_sender_id     (sender_id)
#
# Foreign Keys
#
#  recipient_id  (recipient_id => users.id)
#  sender_id     (sender_id => users.id)
#
class FollowRequest < ApplicationRecord
  belongs_to :recipient, class_name: 'User'
  belongs_to :sender, class_name: 'User'


  enum status: { pending: "pending", rejected: "rejected", accepted: "accepted"}

  validates :recipient_id, uniqueness: { scope: :sender_id, message: "already requested" }

  validate :sender_is_not_recipient
  validates :recipient, presence: true

  private

  def sender_is_not_recipient
    if sender_id == recipient_id
      errors.add(:sender, "can't follow themselves")
    end
  end
end
