# frozen_string_literal: true

# This brings the user group author ability to blog posts from 0.25.
#
# This can be removed after upgrade to 0.25.
module AdminBlogPostsControllerExtensions
  extend ActiveSupport::Concern

  included do
    helper_method :user_group_select_field
  end

  private

  def user_group_select_field(form, name, options = {})
    user_groups = Decidim::UserGroups::ManageableUserGroups.for(current_user).verified
    form.select(
      name,
      user_groups.map { |g| [g.name, g.id] },
      selected: @form.user_group_id.presence,
      include_blank: current_user.name,
      label: options.has_key?(:label) ? options[:label] : true
    )
  end
end
