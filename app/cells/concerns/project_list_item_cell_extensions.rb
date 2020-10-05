# frozen_string_literal: true

# Customizes the budget list item cell
module ProjectListItemCellExtensions
  extend ActiveSupport::Concern

  included do
    private

    def data_class
      [].tap do |list|
        list << "budget-list__data--added" if can_have_order? && resource_added?
        # list << "show-for-medium" if voting_finished? || (current_order_checked_out? && !resource_added?)
      end.join(" ")
    end
  end

  private

  def resource_description
    translated_attribute model.description
  end

  def resource_description_teaser
    truncate(
      # Add a new line in-between the closing and opening tags for the text to
      # have spaces when the tags are removed. Otherwise the text would wrap as
      # the same long word.
      strip_tags(resource_description.gsub(%r{(</[^>]+>)(<[^>]+>)}, "\\1\n\\2")),
      length: 200
    )
  end
end
