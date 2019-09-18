# frozen_string_literal: true

module Helsinki
  class SuomifiMetadataCollector < Decidim::Suomifi::Verification::MetadataCollector
    def metadata
      base = super

      base.tap do |data|
        postal_code = base[:postal_code]

        unless postal_code.blank?
          data[:district] = Helsinki::DistrictMetadata.subdivision_for_postal_code(
            postal_code
          )
        end
      end
    end
  end
end
