# frozen_string_literal: true

# The registrations controller overrides the core functionality because the user
# is redirected to the application root path in case they are not logged in
# prior to trying to accept or decline an invitaiton.
module MeetingsRegistrationsControllerExtensions
  extend ActiveSupport::Concern

  included do
    def create
      enforce_permission_to :join, :meeting, meeting: meeting

      return redirect_to(meeting_path(meeting)) if meeting.has_registration_for?(current_user)

      @form = JoinMeetingForm.from_params(params)

      JoinMeeting.call(meeting, current_user, @form) do
        on(:ok) do
          flash[:notice] = I18n.t("registrations.create.success", scope: "decidim.meetings")
          redirect_after_path
        end

        on(:invalid) do
          flash.now[:alert] = I18n.t("registrations.create.invalid", scope: "decidim.meetings")
          redirect_after_path
        end
      end
    end
  end
end
