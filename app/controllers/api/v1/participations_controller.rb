class Api::V1::ParticipationsController < ApiController
  before_filter except: [:index] do
    find_entity type: :user, id_param: :user_id
  end
  authorize_resource
  check_authorization

  def index
    participants = find_participantable.participants
    render json: participants
  end

  def create
    participantable = find_participantable

    invitation_params[:emails].each do |email|
      Participation.create(email: email, participantable: participantable, sender: current_user)
    end if participant_params[:emails]

    invitation_params[:user_ids].each do |user_id|
      Participation.create(user: User.find(user_id), participantable: participantable, sender: current_user)
    end if participant_params[:user_ids]

    render nothing: true
  end

  def destroy
    find_participantable.participants.destroy(user: @user)
    render nothing: true
  end

protected
  def participant_params
    params.permit(:messaage, emails: [], user_ids: [])
  end

  def find_participantable
    klass = [Event, List].detect {|c| params["#{c.name.underscore}_id"]}
    klass.find(params["#{klass.name.underscore}_id"])
  end
end