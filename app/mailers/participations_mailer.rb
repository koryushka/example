class ParticipationsMailer < ActionMailer::Base
  default from: 'no-reply@curagolife.com'

  def invitation(participation)
    @participation = participation
    @entity_name = @participation.participationable_type.downcase
    recepient_email = participation.email
    recepient_email = participation.user.email if recepient_email.nil? && participation.user.present?
    if recepient_email.present?
      mail(to: recepient_email, subject: 'Invitation')
    else
      logger.debug "Participation #{participation.id} does not contain email and user."
    end
  end
end