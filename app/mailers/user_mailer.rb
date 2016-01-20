class UserMailer < ActionMailer::Base
  default from: 'no-reply@cinemapolls.null'

  def welcome(user)
    mail(to: user.email, subject: 'Welcome to Cinema Polls!')
  end

  def password_recovery(user)
    require 'securerandom'
    symbols = [('a'..'z'), ('A'..'Z'), (1..9)].map { |i| i.to_a }.flatten
    reset_sequence = (0...5).map { symbols[rand(symbols.length)] }.join

    @pwd_recovery = PasswordRecovery.new(
        user: user,
        code: reset_sequence
    )
    @pwd_recovery.save
    mail(to: user.email, subject: 'Cinema Polls: Password reset')
  end
end