# frozen_string_literal: true

module Helsinki
  class MpassidMetadataCollector < Decidim::Mpassid::Verification::MetadataCollector
    def metadata
      super.tap do |data|
        school_codes = saml_attributes[:school_code]

        unless school_codes.blank?
          postal_codes = school_codes.map do |school_code|
            Helsinki::SchoolMetadata.postal_code_for_school(school_code)
          end
          voting_units = school_codes.map do |school_code|
            Helsinki::SchoolMetadata.voting_unit_for_school(school_code)
          end

          data[:postal_code] = postal_codes.join(",")
          data[:voting_unit] = voting_units.join(",")
        end
      end
    end
  end
end
