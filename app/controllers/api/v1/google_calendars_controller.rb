class Api::V1::GoogleCalendarsController < ApiController
  # include GoogleAuth
  # before_action :google_auth, only: [:sync]
  before_action :set_calendar, only: [:unsync_calendar, :sync_calendar]
  before_action :set_account, only: [:sync_account, :unsync_account]

  def unsync_calendar
    @calendar.unsync! if @calendar
    render nothing: true
  end

  def sync_calendar
    @calendar.sync! if @calendar
    render nothing: true
  end

  def accounts
    @accounts = current_user.google_access_tokens
  end

  def unsync_account
    @account.unsync! if @account
    render nothing: true
  end

  def sync_account
    @account.sync! if @account
    render nothing: true
  end

  private

  def set_calendar
    @calendar = current_user.calendars.find(params[:id])
  end

  def set_account
    @account = current_user.google_access_tokens.find(params[:id])
  end
end
