
class Participation
  include Swagger::Blocks

  swagger_schema :Participation do
    key :type, :object
    property :identifier do
      key :type, :string
      key :description, 'Calendar item ID'
    end
    property :participant do
      key :type, :string
      key :description, 'User ID with whom to share'
    end
    property :sharedBy do
      key :type, :string
      key :description, 'User ID who shares'
    end
    property :startDate do
      key :type, :string
      key :format, 'date-time'
      key :description, 'Optional start date and time for share'
    end
    property :endDate do
      key :type, :string
      key :format, 'date-time'
      key :description, 'Optional end date and time for share'
    end
    property :readOnly do
      key :type, :boolean
      key :description, 'Specifies if this is read only share'
      key :default, true
    end
    property :sharedItem do
      key :type, :object
      key :description, 'Item to be shared. It should be only one item - calendar, calendar group, calendar item,
document or list'
      property :calendar do
        key :type, :string
        key :description, 'Optional calendar ID to be shared'
      end
      property :calendarGroup do
        key :type, :string
        key :description, 'Optional calendar group ID to be shared'
      end
      property :calendarItem do
        key :type, :string
        key :description, 'Optional calendar item ID to be shared'
      end
      property :document do
        key :type, :string
        key :description, 'Optional document ID to be shared'
      end
      property :list do
        key :type, :string
        key :description, 'Optional list ID to be shared'
      end
    end
  end # end swagger_schema :Participation
end