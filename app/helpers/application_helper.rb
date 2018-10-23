module ApplicationHelper
  # Defines whether the "common" content elements are displayed. In the
  # 'private' application mode these should be hidden in case the user is not
  # signed in.
  def display_common_elements?
    if is_private_mode?
      return user_signed_in?
    end
    true
  end

  def is_private_mode?
    Rails.application.config.use_mode == 'private'
  end
end
