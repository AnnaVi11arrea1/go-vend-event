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


  def self.ransackable_associations(auth_object = nil)
    []
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[name paid application_status]
  end

  def self.search(search)
    if search
      where('name LIKE ? OR application_status LIKE ? OR paid LIKE ?', "%#{search}%", "%#{search}%", "%#{search}%")
    else
      all
    end
  end

end
