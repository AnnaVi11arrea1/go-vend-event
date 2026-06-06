# == Schema Information
#
# Table name: notes
#
#  id              :integer          not null, primary key
#  content         :text
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  user_id         :integer          not null
#  vendor_event_id :integer          not null
#
# Indexes
#
#  index_notes_on_user_id          (user_id)
#  index_notes_on_vendor_event_id  (vendor_event_id)
#
# Foreign Keys
#
#  user_id          (user_id => users.id)
#  vendor_event_id  (vendor_event_id => vendor_events.id)
#
class Note < ApplicationRecord
  belongs_to :vendor_event
  belongs_to :user

  validate :content_must_have_text
  has_many_attached :images

  private

  def content_must_have_text
    plain_text = ActionController::Base.helpers.strip_tags(content.to_s).squish
    errors.add(:content, "can't be blank") if plain_text.blank?
  end
end
