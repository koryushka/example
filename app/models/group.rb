class Group < AbstractModel
  include Swagger::Blocks

  belongs_to :owner, class_name: 'User', foreign_key: 'user_id'
  has_and_belongs_to_many :members, class_name: 'User'

  validates :title, presence: true, length: {maximum: 128}

  # ================================================================================
  # Swagger::Blocks
  # Swagger::Blocks is a DSL for pure Ruby code blocks that can be turned into JSON.
  # SWAGGER SCHEMA: Model Group
  # ================================================================================

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

end
