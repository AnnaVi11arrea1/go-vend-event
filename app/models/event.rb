# == Schema Information
#
# Table name: events
#
#  id                 :bigint           not null, primary key
#  address            :text
#  application_due_at :date
#  application_link   :string
#  information        :text
#  latitude           :float
#  longitude          :float
#  name               :string
#  started_at         :date
#  tags               :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
class Event < ApplicationRecord
  belongs_to :user
  has_many :vendor_event
end
