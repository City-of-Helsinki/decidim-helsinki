module ApplicationHelper
  # Defines whether the "common" content elements are displayed. In the
  # 'private' application mode these should be hidden in case the user is not
  # signed in.
  def display_common_elements?
    if Rails.application.config.use_mode == 'private'
      return user_signed_in?
    end
    true
  end
end
