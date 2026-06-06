# == Schema Information
#
# Table name: tickets
#
#  id              :integer          not null, primary key
#  admin_response  :text
#  message         :text             not null
#  responded_at    :datetime
#  status          :integer          default("open"), not null
#  subject         :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  responded_by_id :integer
#  user_id         :integer          not null
#
# Indexes
#
#  index_tickets_on_created_at       (created_at)
#  index_tickets_on_responded_by_id  (responded_by_id)
#  index_tickets_on_status           (status)
#  index_tickets_on_user_id          (user_id)
#
# Foreign Keys
#
#  responded_by_id  (responded_by_id => users.id)
#  user_id          (user_id => users.id)
#
class Ticket < ApplicationRecord
  belongs_to :user
  belongs_to :responded_by, class_name: "User", optional: true

  enum status: {
    open: 0,
    in_progress: 1,
    resolved: 2
  }

  validates :subject, presence: true
  validates :message, presence: true

  scope :old_open, -> { open.where("created_at < ?", 72.hours.ago) }
  scope :unanswered, -> { where(admin_response: [nil, ""]) }
end
