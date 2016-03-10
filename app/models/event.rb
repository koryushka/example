class Event < ActiveRecord::Base
  belongs_to :user
  has_and_belongs_to_many :calendars
  has_and_belongs_to_many :documents
  has_one :notifications_preference
  has_many :complex_events, foreign_key: 'id'

  validates :title, length: {maximum: 128}, presence: true
  validates :starts_at, date: true, presence: true
  validates :ends_at, date: true, presence: true
  validates :separation, numericality: { only_integer: true }, allow_blank: true
  validates :count, numericality: { only_integer: true }, allow_blank: true
  validates :until, date: true, allow_blank: true
  validates :notes, length: {maximum: 2048}
  validates :kind, allow_blank: true, numericality: {only_integer: true}
  validates :longitude, numericality: {only_integer: false}, allow_blank: true
  validates :latitude, numericality: {only_integer: false}, allow_blank: true
  validates :frequency, inclusion: {in: %w(once daily weekly monthly yearly)}
end