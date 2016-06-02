class List < AbstractModel
  include Swagger::Blocks

  belongs_to :user
  has_many :list_items, dependent: :destroy
  has_many :events
  has_many :participations, as: :participationable, dependent: :destroy
  has_many :activities, as: :notificationable, dependent: :destroy

  LIST_KINDS = [GROCERY = 1, TODO = 2]

  validates :title, length: {maximum: 128}, presence: true
  validates :notes, length: {maximum: 2048}, exclusion: { in: [nil] }
  validates :kind, numericality: {only_integer: true}, inclusion: {in: LIST_KINDS}

  default :public, true

  # ================================================================================
  # Swagger::Blocks
  # Swagger::Blocks is a DSL for pure Ruby code blocks that can be turned into JSON.
  # SWAGGER SCHEMA: Model List
  # ================================================================================

  #swagger_schema :List
  swagger_schema :List do
    key :type, :object
    property :id do
      key :type, :string
      key :description, 'List ID'
    end
    property :title do
      key :type, :string
      key :description, 'List title'
    end
    property :user_id do
      key :type, :string
      key :description, 'User ID who created this list'
    end
    property :notes do
      key :type, :string
      key :description, 'Additional notes'
    end
    property :kind do
      key :type, :integer
      key :description, 'Specified type of list. Can be 1 - Grocery, 2 - ToDo'
    end
    property :items do
      key :type, :array
      items do
        key :'$ref', :ListItem
      end
    end
    property :participations do
      key :type, :array
      items do
        key :'$ref', :Participation
      end
    end
    property :public do
      key :type, :boolean
      key :description, "Specifies list. If it's true so all family members across my family should be able to modify
all attributes of the list with the exception of changing the ‘Public / Private’ setting"
      key :default, true
    end
  end # end swagger_schema :List

  # swagger_schema :ArrayOfLists
  swagger_schema :ArrayOfLists do
    key :type, :array
    items do
      key :'$ref', :List
    end
  end # end swagger_schema :ArrayOfLists

  # swagger_schema :ListInput
  swagger_schema :ListInput do
    key :type, :object
    key :required, %w(title)
    property :title do
      key :type, :string
      key :description, 'List title'
      key :maxLength, 128
    end
    property :notes do
      key :type, :string
      key :description, 'Additional notes'
      key :maxLength, 2048
    end
    property :kind do
      key :type, :integer
      key :description, 'Specified type of list. Can be 1 - Grocery, 2 - ToDo'
    end
    property :public do
      key :type, :boolean
      key :description, "Specifies list. If it's true so all family members across my family should be able to modify
all attributes of the list with the exception of changing the ‘Public / Private’ setting"
      key :default, true
    end
  end # end swagger_schema :ListInput

end
