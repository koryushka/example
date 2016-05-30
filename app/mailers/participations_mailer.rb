class ParticipationsMailer < ActionMailer::Base
  default from: 'no-reply@curagolife.com'

  def invitation(participation)
    @participation = participation
    @entity_name = @participation.participationable_type.downcase
    mail(to: participation.email, subject: 'Invitation')
  end
end