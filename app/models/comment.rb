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

  belongs_to :author, class_name: 'User'
  belongs_to :event

  has_rich_text :body


  validates :body, presence: true
  validates :author, presence: true
  validates :event, presence: true

end
