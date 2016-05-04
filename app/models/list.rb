class List < AbstractModel
  belongs_to :user
  has_many :list_items, dependent: :destroy
  has_many :events
  has_many :participations, as: :participationable
  has_many :activities, as: :notificationable

  LIST_KINDS = [GROCERY = 1, TODO = 2]

  validates :title, length: {maximum: 128}, presence: true
  validates :notes, length: {maximum: 2048}, exclusion: { in: [nil] }
  validates :kind, numericality: {only_integer: true}, inclusion: {in: LIST_KINDS}
end
