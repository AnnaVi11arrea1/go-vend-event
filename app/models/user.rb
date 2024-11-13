# == Schema Information
#
# Table name: users
#
#  id           :bigint           not null, primary key
#  about        :text
#  avatar       :string
#  email        :string
#  first_name   :string
#  last_name    :string
#  password     :string
#  social_media :string
#  username     :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
class User < ApplicationRecord
  has_many :events
  has_many :vendor_events through: :events # vendor_events is a join table
end
