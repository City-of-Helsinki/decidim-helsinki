# frozen_string_literal: true

module Helsinki
  class MpassidMetadataCollector < Decidim::Mpassid::Verification::MetadataCollector
    def metadata
      super.tap do |data|
        school_codes = data[:school_code]

        if school_codes.present?
          school_codes = school_codes.split(",")
          postal_codes = school_codes.map do |school_code|
            Helsinki::SchoolMetadata.postal_code_for_school(school_code)
          end
          voting_units = school_codes.map do |school_code|
            Helsinki::SchoolMetadata.voting_unit_for_school(school_code)
          end

          data[:postal_code] = postal_codes.join(",")
          data[:voting_unit] = voting_units.join(",")
          data[:municipality] = "091" if postal_codes.any?
        end
      end
    end
  end
end
