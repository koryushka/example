class Group < AbstractModel
  include Swagger::Blocks

  belongs_to :owner, class_name: 'User', foreign_key: 'user_id'
  has_and_belongs_to_many :members, class_name: 'User'
  has_many :participations, as: :participationable
  has_many :activities, as: :notificationable

  alias_attribute :user, :owner

  before_destroy { members.clear }

  validates :title, presence: true, length: {maximum: 128}

  def create_participation(sender, user)
    # TODO: must be combined into single query
    participation = Participation.where(user: user, participationable_type: Group.name)
                        .where.not(sender: sender, status: Participation::FAILED).exists?
    failed_participation = Participation.where(user: user,
                                               participationable: self,
                                               sender: sender,
                                               status: Participation::FAILED).first
    if participation && failed_participation.nil?
      Participation.create(user: user,
                           participationable: self,
                           sender: sender,
                           status: Participation::FAILED)
    else
      Participation.create(user: user,
                           participationable: self,
                           sender: sender)
    end
  end

  # TODO: should be removed if unnecessary
  def accept_participation(participation)
    members << participation.user
  end

  swagger_schema :Group do
    key :type, :object
    property :id do
      key :type, :integer
    end
    property :title do
      key :type, :string
      key :description, 'Group name'
    end
    property :owner_id do
      key :type, :integer
    end
    property :participations do
      key :type, :array
      items do
        key :'$ref', :Participation
      end
    end
  end

  swagger_schema :GroupInput do
    key :type, :object
    key :required, [:title]
    property :title do
      key :type, :string
      key :description, 'Group title'
    end
  end

end
