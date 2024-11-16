# == Schema Information
#
# Table name: events
#
#  id                 :bigint           not null, primary key
#  address            :string
#  application_due_at :date
#  application_link   :string
#  information        :string
#  latitude           :float
#  longitude          :float
#  name               :string
#  started_at         :date
#  tags               :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  host_id            :integer
#
class Event < ApplicationRecord
  belongs_to :host, class_name: "User", foreign_key: "host_id"
  has_many :vendorevents, class_name: "VendorEvent", foreign_key: "event_id", dependent: :destroy
  def self.ransackable_attributes(auth_object = nil)
    %w[name address tags started_at]
  end

  def self.ransackable_associations(auth_object = nil)
    []
  end

  def self.search(search)
    if search
      where('name LIKE ? OR address LIKE ? OR tags LIKE ?', "%#{search}%", "%#{search}%", "%#{search}%")
    else
      all
    end
  end

  def self.search_by_date(search)
    if search
      where('started_at = ?', "%#{search}%")
    else
      all
    end
  end

end
