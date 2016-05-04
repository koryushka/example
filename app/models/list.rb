class List < AbstractModel
  include Swagger::Blocks

  belongs_to :user
  has_many :list_items, dependent: :destroy
  LIST_KINDS = [Grocery = 1, ToDo = 2]

  validates :title, length: {maximum: 128}, presence: true
  validates :notes, length: {maximum: 2048}, exclusion: { in: [nil] }
  validates :kind, numericality: {only_integer: true}, inclusion: {in: LIST_KINDS}

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
        key :'$ref', '#/definitions/ListItem'
      end
    end
  end # end swagger_schema :List

  # swagger_schema :ArrayOfLists
  swagger_schema :ArrayOfLists do
    key :type, :array
    items do
      key :'$ref', '#/definitions/List'
    end
  end # end swagger_schema :ArrayOfLists

  # swagger_schema :ListInput
  swagger_schema :ListInput do
    key :type, :object
    property :title do
      key :type, :string
      key :description, 'List title'
    end
    property :notes do
      key :type, :string
      key :description, 'Additional notes'
    end
    property :kind do
      key :type, :integer
      key :description, 'Specified type of list. Can be 1 - Grocery, 2 - ToDo'
    end
  end # end swagger_schema :ListInput

end
