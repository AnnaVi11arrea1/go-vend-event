# == Schema Information
#
# Table name: comments
#
#  id         :integer          not null, primary key
#  body       :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  author_id  :bigint           not null
#  event_id   :bigint           not null
#
# Foreign Keys
#
#  author_id  (author_id => users.id)
#  event_id   (event_id => events.id)
#
class Comment < ApplicationRecord

  belongs_to :event
  has_one :author, through: :author_id, source: "User", foreign_key: "usernanme"
  has_one :event, through: :event_id, source: "Event", foreign_key: "name"

  validates :body, presence: true
end
