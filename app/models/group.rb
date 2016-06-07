class Group < AbstractModel
  include Swagger::Blocks

  belongs_to :owner, class_name: 'User', foreign_key: 'user_id'
    has_many :participations, as: :participationable, dependent: :destroy
  has_many :activities, as: :notificationable, dependent: :destroy

  alias_attribute :user, :owner

  validates :title, presence: true, length: {maximum: 128}

  def create_participation(sender, user)
    # TODO: must be combined into single query
    participation = Participation.where(user: user, participationable_type: Group.name)
                        .where.not(sender: sender, status: Participation::FAILED).exists?
    failed_participation = Participation.where(user: user,
                                               participationable: self,
                                               sender: sender,
                                               status: Participation::FAILED).first
    # if invitation was failed for other group and it does not exist for current croup
    # we need to create failed participation for current group
    if (participation || user.family.present?) && failed_participation.nil?
      Participation.create(user: user,
                           participationable: self,
                           sender: sender,
                           status: Participation::FAILED)
    else
      participation = Participation.create(user: user,
                           participationable: self,
                           sender: sender,
                           status: Participation::ACCEPTED)

      notify_members
      participation
    end
  end

  def leave(user)
    participation = participations.where(user: user)
    participations.delete(participation)
    notify_members
  end

  def members
    owner = User.where(id: user_id).select(:id)
    participants = Participation.groups
                       .where(status: Participation::ACCEPTED, participationable_id: id)
                       .select(:user_id)
    User.where("users.id IN (#{owner.to_sql}) OR users.id IN (#{participants.to_sql})")
  end
private
  def notify_members
    members.pluck(:id).each do |user_id|
      PubnubHelper::Publisher.publish('group participation changed', user_id)
    end
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
    property :owner do
      key :'$ref', :UserWithProfileOnly
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
      key :maxLength, 128
    end
  end

end
