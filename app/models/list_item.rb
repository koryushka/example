class ListItem < AbstractModel
  belongs_to :list
  belongs_to :user
  has_many :activities, as: :notificationable

  validates :title, length: {maximum: 128}, presence: true
  validates :notes, length: {maximum: 2048}
  validates :done, allow_blank: true, inclusion: {in: [true, false]}
  validates :order, allow_blank: true, numericality: {only_integer: true}

  default :notes, ''
  default :done, false
  default :order, 0
end
