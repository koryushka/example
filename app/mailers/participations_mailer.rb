class ParticipationsMailer < ActionMailer::Base
  default from: 'no-reply@curagolife.com'

  def invitation(participation)
    @participation = participation
    mail(to: participation.email, subject: 'Invitation')
  end
end