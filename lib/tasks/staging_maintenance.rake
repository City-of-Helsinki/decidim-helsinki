# frozen_string_literal: true

namespace :staging_maintenance do
  task environment: [:environment] do
    raise "This command is limited to the staging environment only." unless Rails.env.match?(/\Astaging(_|\z)/)
  end

  # Because the accounts may need to be reused
  desc "Finds all MPASSid authorizations and clears them and the user accounts attached to them."
  task clear_mpassid_accounts: [:"staging_maintenance:environment"] do
    form = Decidim::DeleteAccountForm.new(delete_reason: "Asiakkaan pyyntö")
    Decidim::Authorization.where(name: "mpassid_nids").each do |auth|
      puts "Processing authorization: #{auth.id}"

      user = auth.user
      if user && !user.deleted?
        puts "Deleting attached user: #{user.id}"
        Decidim::DestroyAccount.call(user, form)
      end

      auth.destroy!
    end

    puts "All authorizations processed."
  end
end
