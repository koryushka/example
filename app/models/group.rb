class Group < AbstractModel
  belongs_to :owner, class_name: 'User', foreign_key: 'user_id'
  has_and_belongs_to_many :members, class_name: 'User'

  validates :title, presence: true, length: {maximum: 128}
end
