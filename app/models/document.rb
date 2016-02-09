class Document < ActiveRecord::Base
  belongs_to :user
  has_and_belongs_to_many :calendar_items
  belongs_to :uploaded_file

  validates :title, length: {maximum: 128}, presence: true
  validates :notes, length: {maximum: 2048}
  validates :tags, length: {maximum: 2048}
  validates_presence_of :uploaded_file
end
