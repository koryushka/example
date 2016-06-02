class Device < ActiveRecord::Base
  include Swagger::Blocks
  belongs_to :user

  validates :device_token, presence: true

  # ================================================================================
  # Swagger::Blocks
  # Swagger::Blocks is a DSL for pure Ruby code blocks that can be turned into JSON.
  # SWAGGER SCHEMA: Model Device
  # ================================================================================

  # swagger_schema :Device
  swagger_schema 'Device' do
    key :type, :object
    property :id do
      key :type, :integer
      key :description, 'Device ID'
    end
    property :device_token do
      key :type, :string
      key :description, 'Token of device obtained from iOS application'
    end
  end # end swagger_schema :Device

  # swagger_schema :DeviceInput
  swagger_schema 'DeviceInput' do
    key :type, :object
    key :required, [:device_token]
    property :device_token do
      key :type, :string
      key :description, 'Token of device obtained from iOS application'
    end
  end # end swagger_schema :DeviceInput
end
