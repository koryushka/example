class List < ActiveRecord::Base
  belongs_to :user
  has_many :items, class_name: 'ListItem'

  validates :title, length: {maximum: 128}, presence: true
  validates :notes, length: {maximum: 2048}
end
