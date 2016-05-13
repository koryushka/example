class Group < AbstractModel
  include Swagger::Blocks

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

  # ================================================================================
  # Swagger::Blocks
  # Swagger::Blocks is a DSL for pure Ruby code blocks that can be turned into JSON.
  # SWAGGER SCHEMA: Model Group
  # ================================================================================

  # swagger_schema :Group
  swagger_schema :Group do
    key :type, :object
    property :id do
      key :type, :integer
    end
    property :title do
      key :type, :string
      key :description, 'Group name'
    end
  end # end swagger_schema :Group

  swagger_schema :GroupInput do
    key :type, :object
    key :required, [:title]
    property :title do
      key :type, :string
      key :description, 'Group title'
    end
  end # end swagger_schema :GroupInput

end
