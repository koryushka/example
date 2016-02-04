class Calendar < ActiveRecord::Base
  belongs_to :user
  has_many :calendar_items
  has_and_belongs_to_many :calendars_groups

  validates :title, length: {maximum: 128}, presence: true
  validates :hex_color, length: {maximum: 6}
  validates :main, allow_blank: true, inclusion: {in: [true, false]}
  validates :kind, allow_blank: true, numericality: {only_integer: true}
  validates :visible, allow_blank: true, inclusion: {in: [true, false]}
end