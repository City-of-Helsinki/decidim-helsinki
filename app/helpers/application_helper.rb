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

  # Replace the footer koro with a custom one. E.g. a specific background color
  # may need to be added to the footer koro element depending on the previous
  # element.
  def replace_footer_koro(extra_cls)
    content_for :footer_koro, flush: true do
      ('<div class="koro-top ' + extra_cls + '"></div>').html_safe
    end
  end

  def link_to_or_back(*args, &block)
    body = args.shift
    path = if block_given?
      body
    else
      args.shift
    end

    if params[:back_to] =~ /^(\/[a-z0-9-]*)+$/
      path = params[:back_to]
    end

    if block_given?
      link_to(path, *args, &block)
    else
      link_to(body, path, *args)
    end
  end
end
