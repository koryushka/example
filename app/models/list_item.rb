class ListItem < ActiveRecord::Base
  belongs_to :list

  validates :title, length: {maximum: 128}, presence: true
  validates :notes, length: {maximum: 2048}
end
