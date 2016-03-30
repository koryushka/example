class ListItem < ActiveRecord::Base
  belongs_to :list
  belongs_to :user

  validates :title, length: {maximum: 128}, presence: true
  validates :notes, length: {maximum: 2048}
  validates :done, allow_blank: true, inclusion: {in: [true, false]}
  validates :order, allow_blank: true, numericality: {only_integer: true}
end
