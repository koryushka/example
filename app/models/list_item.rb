class ListItem < AbstractModel
  include Swagger::Blocks

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

  # ================================================================================
  # Swagger::Blocks
  # Swagger::Blocks is a DSL for pure Ruby code blocks that can be turned into JSON.
  # SWAGGER SCHEMA: Model List Item
  # ================================================================================

  # swagger_schema :ListItem
  swagger_schema :ListItem do
    key :type, :object
    property :id do
      key :type, :integer
      key :description, 'List item ID'
    end
    property :title do
      key :type, :string
      key :description, 'List item title'
    end
    property :notes do
      key :type, :string
      key :description, 'Additional notes'
    end
    property :order do
      key :type, :integer
      key :format, :int16
      key :description, 'Sorting order for item in the list'
      key :default, 0
    end
    property :done do
      key :type, :boolean
      key :description, 'Shows whether user finished with this item or not'
      key :default, false
    end
  end # end swagger_schema :ListItem

  # swagger_schema :ArrayOfListItems
  swagger_schema :ArrayOfListItems do
    key :type, :array
    items do
      key :'$ref', :ListItem
    end
  end # swagger_schema :ArrayOfListItems

  # swagger_schema :ListItemInput
  swagger_schema :ListItemInput do
    key :type, :object
    key :required, [:title]
    property :title do
      key :type, :string
      key :description, 'List item title'
      key :maxLength, 128
    end
    property :notes do
      key :type, :string
      key :description, 'Additional notes'
      key :maxLength, 2048
    end
    property :order do
      key :type, :integer
      key :format, :int16
      key :description, 'Sorting order for item in the list'
      key :default, 0
    end
    property :done do
      key :type, :boolean
      key :description, 'Shows whether user finished with this item or not'
      key :default, false
    end
  end # end :ListItemInput

end
