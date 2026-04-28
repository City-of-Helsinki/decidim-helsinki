# frozen_string_literal: true

class UpdateCategoryImageStorageAttachmentName < ActiveRecord::Migration[6.1]
  def up
    ActiveStorage::Attachment.where(
      record_type: "Decidim::Category",
      name: "category_image"
    ).update_all(name: "category_images") # rubocop:disable Rails/SkipsModelValidations
  end

  def down
    ActiveStorage::Attachment.where(
      record_type: "Decidim::Category",
      name: "category_images"
    ).update_all(name: "category_image") # rubocop:disable Rails/SkipsModelValidations
  end
end
