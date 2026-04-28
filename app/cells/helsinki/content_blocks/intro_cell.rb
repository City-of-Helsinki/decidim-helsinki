# frozen_string_literal: true

module Helsinki
  module ContentBlocks
    class IntroCell < Decidim::ViewModel
      include Decidim::LayoutHelper
      include KoroHelper

      private

      def unique_id
        @unique_id ||= SecureRandom.hex(3).to_s
      end

      def title
        translated_attribute(model.settings.title)
      end

      def description
        translated_attribute(model.settings.description)
      end

      def description_fragment
        @description_fragment ||= Nokogiri::HTML::DocumentFragment.parse(description)
      end

      def description_intro
        @description_intro ||= begin
          intro_node = description_fragment.children.find { |node| node.name != "text" }
          intro_node&.to_html&.strip || ""
        end
      end

      def description_extra
        @description_extra ||= begin
          extra_nodes = []
          cutpoint_found = false

          description_fragment.children.each do |node|
            unless cutpoint_found
              next if node.name == "text"

              cutpoint_found = true
              next
            end

            extra_nodes << node.to_html.strip
          end

          extra_nodes.join("\n").strip
        end
      end

      def main_image
        model.images_container.attached_uploader(:main_image).variant_url(:default)
      end

      def main_image_alt
        translated_attribute(model.settings.main_image_alt)
      end
    end
  end
end
