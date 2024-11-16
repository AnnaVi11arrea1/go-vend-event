# == Schema Information
#
# Table name: vendor_events
#
#  id                 :bigint           not null, primary key
#  added              :boolean
#  application_status :string
#  paid               :boolean
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  event_id           :integer
#  user_id            :integer
#
class VendorEvent < ApplicationRecord
  belongs_to :user, required: true, class_name: "User", foreign_key: 'user_id'
  belongs_to :event, required: true, class_name: "Event", foreign_key: 'event_id'
  

  # has_one :event_name, through: "Event", source: :name
end
