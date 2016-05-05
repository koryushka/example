class Profile < AbstractModel
  belongs_to :user

  validates :full_name, length: {maximum: 64}
  validates :image_url, length: {maximum: 2048}
  validates :color, length: {maximum: 6}

  default :first_name, ''
  default :last_name, ''
  default :full_name, ''

  # ================================================================================
  # Swagger::Blocks
  # Swagger::Blocks is a DSL for pure Ruby code blocks that can be turned into JSON.
  # SWAGGER SCHEMA: Model Profile
  # ================================================================================

  #swagger_schema Profile:
  swagger_schema :Profile do
    key :type, :object
    property :id do
      key :type, :integer
    end
    property :user_id do
      key :type, :integer
    end
    property :full_name do
      key :type, :string
    end
    property :image_url do
      key :type, :string
      key :description, 'Avatar URL'
    end
    property :color do
      key :type, :string
      key :description, 'Hex string representation of color'
    end
  end # end swagger_schema :Profile

  # swagger_schema :ProfileInput
  swagger_schema :ProfileInput do
    key :type, :object
    property :full_name do
      key :type, :string
    end
    property :image_url do
      key :type, :string
      key :description, 'Avatar URL'
    end
    property :color do
      key :type, :string
      key :description, 'Hex string representation of color'
    end
  end # end swagger_schema ProfileInput

end