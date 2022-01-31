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

  # Usage:
  #  bundle exec rails moderation:suspicious[tmp/suspicious-users.csv]
  desc "Gets a list of suspicious users and saves it to a CSV file stored at the given location."
  task :suspicious, [:filepath] => [:environment] do |_t, args|
    path = args[:filepath]
    if File.exist?(path)
      print "A file already exists at #{path}"
      next
    end

    # Patterns allowed for the personal URLs
    allowed_url_patterns = [
      %r{^(https?://)?((www|edu|omastadi)\.)?hel.fi},
      %r{^(https?://)?(www\.)?twitter.com(/|$)},
      %r{^(https?://)?(www\.)?instagram.com(/|$)},
      %r{^(https?://)?(www\.)?linkedin.com(/|$)}
    ]

    CSV.open(path, "w", col_sep: ";") do |csv|
      csv << %w(
        nickname
        confirmed
        spammer_score
        profile_url
        email_service
        personal_url
        comment_count
        comments_with_links
        comment_languages
        comment_1
        comment_2
        comment_3
        comment_4
        comment_5
      )

      # Go through only all users who are not authorized as the spammer users
      # are never authorized.
      Decidim::User.joins(
        "LEFT JOIN decidim_authorizations auth ON auth.decidim_user_id = decidim_users.id"
      ).where(auth: { id: nil }).find_each do |user|
        # Users with confirmed emails ending at @hel.fi or @edu.hel.fi should be
        # trustworthy in this context, i.e. not spammers in general.
        next if user.confirmed? && user.email.match?(/@(edu\.)?hel.fi/)

        comments = Decidim::Comments::Comment.not_hidden.where(author: user).order(created_at: :desc)
        languages = []
        comments_with_links = 0
        comments.map do |comment|
          text = comment.body.values.first
          languages << CLD.detect_language(text)[:code]
          comments_with_links += 1 if text.match?(/<a href="/)
        end

        score = 0
        score += 1 if languages.count == 1 && languages.first == "en"
        score += 1 if comments_with_links > 1
        score += 1 if user.personal_url.present? && allowed_url_patterns.none? { |p| user.personal_url.match?(p) }
        next if score.zero?

        csv << [
          user.nickname,
          user.confirmed? ? 1 : 0,
          (score.to_f / 3).round(2),
          "https://#{user.organization.host}/profiles/#{user.nickname}",
          user.email.sub(/^[^@]+@/, ""),
          user.personal_url,
          comments.count,
          comments_with_links,
          languages.uniq.join(",")
        ] + comments.first(5).map { |c| c.body.values.first }
      end
    end
  end
end
