class Group < AbstractModel
  belongs_to :owner, class_name: 'User', foreign_key: 'user_id'
  has_and_belongs_to_many :members, class_name: 'User'
  has_many :participations, as: :participationable
  has_many :activities, as: :notificationable

  alias_attribute :user, :owner

  before_destroy { members.clear }

  validates :title, presence: true, length: {maximum: 128}

  def accept_participation(participation)
    members << participation.user
  end
end
