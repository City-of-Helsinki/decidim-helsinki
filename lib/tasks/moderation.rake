# frozen_string_literal: true

namespace :moderation do
  desc "Moderates and hides all the comments from a specific user and deletes the account + prints their IP."
  task :user, [:user_id_or_nickname] => [:environment] do |_t, args|
    moderator = Decidim::User.find(1)

    user_handle = args[:user_id_or_nickname]
    user =
      if user_handle.match(/^[0-9]+$/)
        Decidim::User.find_by(id: user_handle)
      else
        Decidim::User.find_by(nickname: user_handle)
      end

    unless user
      print "Unknown user with ID or nickname: #{user_handle}"
      next
    end

    Decidim::Comments::Comment.where(author: user).each do |comment|
      moderation = Decidim::Moderation.find_or_create_by!(
        reportable: comment,
        participatory_space: comment.participatory_space
      )
      Decidim::Report.create!(
        moderation: moderation,
        user: moderator,
        reason: "spam",
        details: ""
        # locale: "fi" # later Decidim versions
      )
      Decidim.traceability.perform_action!(
        "hide",
        moderation,
        moderator,
        extra: { reportable_type: comment.class.name }
      ) do
        moderation.update!(hidden_at: Time.current)
        comment.try(:touch)
      end
    end
    user_ip = user.last_sign_in_ip
    form = Decidim::DeleteAccountForm.new(delete_reason: "Spammer")
    Decidim::DestroyAccount.new(user, form).call

    puts "Deleted user '#{user_handle}' and moderated all their comments."
    puts "User IP: #{user_ip}"
  end
end
