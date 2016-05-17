class Api::V1::ParticipationsController < ApiController
  include Swagger::Blocks
  before_filter :find_entity, only: [:destroy, :accept, :decline]
  authorize_resource
  check_authorization

  swagger_path '/{resource}/{resource_id}/participations' do
    operation :get do
      key :summary, 'Shows list of participations for specified resource'
      parameter do
        key :name, :resource
        key :description, "Can be 'lists', 'events' or 'groups'"
        key :type, :string
        key :in, :path
        key :required, true
      end
      parameter do
        key :name, :resource_id
        key :description, "Can be 'lists', 'events' or 'groups'"
        key :type, :integer
        key :in, :path
        key :required, true
      end
      response 200 do
        key :description, 'OK'
        schema do
          key :type, :array
          items do
            key :'$ref', :Participation
          end
        end
      end
      response :default do
        key :description, 'Unexpected error'
        schema do
          key :'$ref', :Error
        end
      end
      key :tags, ['Participations']
    end
  end

  def index
    @participations = find_participationable.participations
                          .includes(sender: :profile, user: :profile)
  end

  swagger_path '/participations' do
    operation :get do
      key :summary, 'Returns recently sent invitations'
      response 200 do
        key :description, 'OK'
        schema do
          key :type, :array
          items do
            key :'$ref', :Participation
          end
        end
      end
      response :default do
        key :description, 'Unexpected error'
        schema do
          key :'$ref', :Error
        end
      end
      key :tags, ['Participations']
    end
  end

  def index_recent
    @participations = current_user.sent_paticipations
                          .includes(sender: :profile, user: :profile)
                          .references(sender: :profile, user: :profile)
                          .select('DISTINCT ON (participations.user_id) participations.id')

    render 'index'
  end

  swagger_path '/{resource}/{resource_id}/participations' do
    operation :post do
      key :summary, 'Adds participants to resource'
      parameter do
        key :name, :resource
        key :description, "Can be 'lists', 'events' or 'groups'"
        key :type, :string
        key :in, :path
        key :required, true
      end
      parameter do
        key :name, :resource_id
        key :description, "Can be 'lists', 'events' or 'groups'"
        key :type, :integer
        key :in, :path
        key :required, true
      end
      parameter do
        key :name, :data
        key :in, :body
        key :required, true
        schema do
          key :'$ref', :ParticipationInput
        end
      end
      response 200 do
        key :description, 'OK'
        schema do
          key :type, :array
          items do
            key :'$ref', :Participation
          end
        end
      end
      response 400 do
        key :description, 'Validation error'
        schema do
          key :'$ref', :ValidationErrorsContainer
        end
      end
      response :default do
        key :description, 'Unexpected error'
        schema do
          key :'$ref', :Error
        end
      end
      key :tags, ['Participations']
    end
  end
  # must be refactoried!
  def create
    participationable = find_participationable
    existing_users = participation_params[:user_ids] || []
    @participations = []

    participation_params[:emails].each do |email|
      # go to next email if user already accepted participation
      next if current_user.sent_paticipations.exists?(email: email,
                                                      participationable_type: participationable.class.name,
                                                      participationable_id: participationable.id,
                                                      status: Participation::ACCEPTED)

      existing_user = User.where(email: email).select(:id).first
      unless existing_user.nil?
        existing_users << existing_user.id
        next
      end

      participation = current_user.sent_paticipations
                          .where(email: email, participationable: participationable).first
      participation = Participation.create(email: email,
                                           participationable: participationable,
                                           sender: current_user) if participation.nil?
      @participations << participation
      ParticipationsMailer.invitation(participation).deliver_now
    end if participation_params[:emails]

    existing_users = existing_users.concat(participation_params[:user_ids]) if participation_params[:user_ids]
    existing_users.each do |user_id|
      next if Participation.exists?(user_id: user_id,
                                    participationable_type: participationable.class.name,
                                    participationable_id: participationable.id,
                                    status: Participation::ACCEPTED)
      user = User.where(id: user_id).first
      next if user.nil?

      if participationable.respond_to? :create_participation
        @participations << participationable.create_participation(current_user, user)
      else
        @participations << Participation.create(user: User.find(user_id),
                                                       participationable: participationable,
                                                       sender: current_user)
      end
    end

    render 'index'
  end


  swagger_path '/{resource}/{resource_id}/participations/{id}' do
    operation :delete do
      key :summary, 'Deletes participation from resource'
      parameter do
        key :name, :resource
        key :description, "Can be 'lists', 'events' or 'groups'"
        key :type, :string
        key :in, :path
        key :required, true
      end
      parameter do
        key :name, :resource_id
        key :description, "Can be 'lists', 'events' or 'groups'"
        key :type, :integer
        key :in, :path
        key :required, true
      end
      parameter do
        key :name, :id
        key :description, 'Participation id'
        key :type, :integer
        key :in, :path
        key :required, true
      end
      response 200 do
        key :description, 'OK'
        schema do
          key :type, :array
          items do
            key :'$ref', :Participation
          end
        end
      end
      response :default do
        key :description, 'Unexpected error'
        schema do
          key :'$ref', :Error
        end
      end
      key :tags, ['Participations']
    end
  end
  def destroy
    find_participationable.participations.destroy(@participation)
    render nothing: true
  end

  swagger_path '/participations/{id}/accept' do
    operation :post do
      key :summary, 'Accepts invitation sent to Curago user'
      parameter do
        key :name, :id
        key :description, 'Participation id'
        key :type, :integer
        key :in, :path
        key :required, true
      end
      response 200 do
        key :description, 'OK'
      end
      response 406 do
        key :description, 'Invitation has been accepted earlier'
      end
      response :default do
        key :description, 'Unexpected error'
        schema do
          key :'$ref', :Error
        end
      end
      key :tags, ['Participations']
    end
  end
  def accept
    raise AlreadyAcceptedException if @participation.accepted?

    # accept_participation means adding to group, event, list, etc.
    #@participation.participationable.accept_participation(@participation)
    @participation.change_status_to(Participation::ACCEPTED)
    render nothing: true
  end

  swagger_path '/participations/{id}/decline' do
    operation :post do
      key :summary, 'Declines invitation sent to Curago user'
      parameter do
        key :name, :id
        key :description, 'Participation id'
        key :type, :integer
        key :in, :path
        key :required, true
      end
      response 200 do
        key :description, 'OK'
      end
      response 406 do
        key :description, 'Invitation has been declined earlier'
      end
      response :default do
        key :description, 'Unexpected error'
        schema do
          key :'$ref', :Error
        end
      end
      key :tags, ['Participations']
    end
  end
  def decline
    raise AlreadyDeclinedException if @participation.declined?

    @participation.change_status_to(Participation::DECLINED)
    render nothing: true
  end

  protected
  def participation_params
    params.permit(:messaage, emails: [], user_ids: [])
  end

  def find_participationable
    klass = [Event, List, Group].detect { |c| params["#{c.name.underscore}_id"] }
    klass.find(params["#{klass.name.underscore}_id"])
  end
end