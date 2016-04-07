class List < ActiveRecord::Base
  belongs_to :user
  has_many :list_items, dependent: :destroy
  LIST_KINDS = [Grocery = 1, ToDo = 2]

  validates :title, length: {maximum: 128}, presence: true
  validates :notes, length: {maximum: 2048}, exclusion: { in: [nil] }
  validates :kind, numericality: {only_integer: true}, inclusion: {in: LIST_KINDS}
end
