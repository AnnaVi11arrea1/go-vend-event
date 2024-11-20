# == Schema Information
#
# Table name: vendor_events
#
#  id                 :bigint           not null, primary key
#  added              :boolean
#  application_status :string
#  paid               :boolean
#  photo              :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  event_id           :integer
#  user_id            :integer
#
class VendorEvent < ApplicationRecord
  belongs_to :user, required: true, class_name: "User", foreign_key: 'user_id'
  belongs_to :event, required: true, class_name: "Event", foreign_key: 'event_id'
  
  delegate :name, to: :event, prefix: true

  has_one_attached :photo
  mount_uploader :photo, PhotoUploader


end
