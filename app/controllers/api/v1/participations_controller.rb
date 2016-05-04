class Api::V1::ParticipationsController < ApiController
  before_filter :find_entity, only: [:destroy, :accept, :decline]
  authorize_resource
  check_authorization

  def index
    @participations = find_participationable.participations
                          .includes(sender: :profile, user: :profile)
  end

  def index_recent
    @participations = current_user.sent_paticipations
                          .includes(sender: :profile, user: :profile)
                          .references(sender: :profile, user: :profile)
                          .select('DISTINCT ON (participations.user_id) participations.id')

    render 'index'
  end

  def create
    participationable = find_participationable

    participation_params[:emails].each do |email|
      Participation.create(email: email,
                           participationable: participationable,
                           sender: current_user)
    end if participation_params[:emails]

    participation_params[:user_ids].each do |user_id|
      Participation.create(user: User.find(user_id),
                           participationable: participationable,
                           sender: current_user)
    end if participation_params[:user_ids]

    render nothing: true
  end

  def destroy
    find_participationable.participations.destroy(@participation)
    render nothing: true
  end

  def accept
    @participation.change_status_to(Participation::ACCEPTED)
    render nothing: true
  end

  def decline
    @participation.change_status_to(Participation::DECLINED)
    render nothing: true
  end

protected
  def participation_params
    params.permit(:messaage, emails: [], user_ids: [])
  end

  def find_participationable
    klass = [Event, List].detect { |c| params["#{c.name.underscore}_id"] }
    klass.find(params["#{klass.name.underscore}_id"])
  end
end