class Api::V1::ParticipantsController < ApiController
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
    Participant.create(user: @user, participantable: find_participantable)
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