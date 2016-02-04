class CalendarItem < ActiveRecord::Base
  belongs_to :user
  has_and_belongs_to_many :calendars
  belongs_to :notifications_preference

  validates :title, length: {maximum: 128}, presence: true
  validates :start_date, date: true, allow_blank: true
  validates :end_date, date: true, allow_blank: true
  validates :notes, length: {maximum: 2048}
  validates :kind, allow_blank: true, numericality: {only_integer: true}
  validates :longitude, numericality: {only_integer: false}, allow_blank: true
  validates :latitude, numericality: {only_integer: false}, allow_blank: true
end