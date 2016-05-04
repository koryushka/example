class List < AbstractModel
  include Swagger::Blocks

  belongs_to :user
  has_many :list_items, dependent: :destroy
  LIST_KINDS = [Grocery = 1, ToDo = 2]

  validates :title, length: {maximum: 128}, presence: true
  validates :notes, length: {maximum: 2048}, exclusion: { in: [nil] }
  validates :kind, numericality: {only_integer: true}, inclusion: {in: LIST_KINDS}

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
end
