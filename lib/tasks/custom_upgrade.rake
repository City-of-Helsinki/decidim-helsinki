# frozen_string_literal: true

namespace :custom_upgrade do
  # Needs to be run after 0.24 upgrade.
  desc "Encrypts the authorization metadata values stored in the database."
  task encrypt_authorization_metadatas: [:environment] do
    puts "Modifying authorizations, this takes a while..."
    puts "-- Total records to process: #{Decidim::Authorization.count}"
    Decidim::Authorization.all.each_with_index do |auth, ind|
      puts "-- Processed #{ind} records" if ind.positive? && (ind % 50).zero?

      # Re-setting these values will internally convert the hash values to
      # encypted values
      auth.update!(
        metadata: auth.metadata,
        verification_metadata: auth.verification_metadata
      )
    end
  end
end
