# == Schema Information
#
# Table name: spreadsheet_data
#
#  id         :bigint           not null, primary key
#  column     :integer
#  row        :integer
#  value      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class SpreadsheetDatum < ApplicationRecord
end
