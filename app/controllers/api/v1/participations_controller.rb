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

  # must be refactoried!
  def create
    participationable = find_participationable
    existing_users = participation_params[:user_ids] || []

    participation_params[:emails].each do |email|
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
      ParticipationsMailer.invitation(participation).deliver_now
    end if participation_params[:emails]

    participation_params[:user_ids].each do |user_id|
      next if Participation.exists?(user_id: user_id,
                                    participationable_type: participationable.class.name,
                                    participationable_id: participationable.id,
                                    status: Participation::ACCEPTED)
      next unless User.exists?(id: user_id)
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
    raise AlreadyAcceptedException if @participation.accepted?

    # process_participation means adding to group, event, list, etc.
    @participation.participationable.accept_participation(@participation)
    @participation.change_status_to(Participation::ACCEPTED)
    render nothing: true
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