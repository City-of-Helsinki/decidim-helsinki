# frozen_string_literal: true
# This migration comes from decidim_feedback (originally 20201001142412)

class CreateDecidimFeedbacks < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_feedback_feedbacks do |t|
      t.integer(
        :decidim_organization_id,
        foreign_key: true,
        index: {
          name: "index_decidim_feedback_feedbacks_on_decidim_organization_id"
        }
      )
      t.integer :rating
      t.text :body, null: false
      t.boolean :contact_request, default: false
      t.jsonb :metadata
      t.references :decidim_user, null: false
      t.references :decidim_feedbackable, polymorphic: true, index: false
      t.timestamps
    end

    add_index :decidim_feedback_feedbacks,
              [:decidim_user_id, :decidim_feedbackable_id, :decidim_feedbackable_type],
              unique: false,
              name: "index_uniq_on_feedbacks_user_and_feedbackable"
    add_index :decidim_feedback_feedbacks,
              [:decidim_feedbackable_id, :decidim_feedbackable_type],
              unique: false,
              name: "index_on_feedbackable"
  end
end
