# frozen_string_literal: true

require "mapstatic"

module Decidim
  module Map
    module Provider
      module StaticMap
        # The static map utility class for the Helsinki map services
        class Helsinki < ::Decidim::Map::StaticMap
          # @see Decidim::Map::StaticMap#image_data
          def image_data(latitude:, longitude:, options: {})
            width = options[:width]
            height = options[:height]
            circle_radius = 10
            attribution_padding = [5, 2]

            map = Mapstatic::Map.new(
              provider: "http://tiles.hel.ninja/styles/hel-osm-bright/{z}/{x}/{y}@fi.png",
              lat: latitude,
              lng: longitude,
              width: width,
              height: height,
              zoom: options[:zoom]
            )

            # Draw the dot in the center of the image
            dot_x = (width / 2).round
            dot_y = (height / 2).round

            image = map.to_image
            image.combine_options do |c|
              c.fill "#ccccf2"
              c.stroke "#0000bf"
              c.strokewidth "2"
              c.draw "circle #{dot_x},#{dot_y} #{dot_x},#{dot_y + circle_radius}"
            end

            apply_attribution(image, width, height, attribution_padding) do |final|
              return final.to_blob
            end
          end

          private

          def apply_attribution(image, width, height, padding)
            padding = [padding, padding] unless padding.is_a?(Array)

            Tempfile.create(["hkistaticmap-attribution", ".png"]) do |temp|
              MiniMagick::Tool::Convert.new do |img|
                img.size "#{width - padding[0] * 2}x"
                img.background "#ffffff80"
                img.fill "#6f6f6f"
                img.font "#{fonts_path}/Roboto-Regular.ttf"
                img.pointsize "12"
                img.gravity "SouthWest"
                img << "caption:© OpenStreetMap contributors"
                # Add bottom-left padding
                img.gravity "SouthWest"
                img.splice "#{padding[0]}x#{padding[1]}"
                # Add top-right padding
                img.gravity "NorthEast"
                img.splice "#{padding[0]}x#{padding[1]}"
                # Exntend the image height
                img.gravity "South"
                img.background "none"
                img.extent "x#{height}"
                img << temp.path
              end

              # Create a composition with the attribution image on top
              attribution = MiniMagick::Image.open(temp.path)
              result = image.composite(attribution) do |c|
                c.compose "Over"
              end

              yield result
            end
          end

          def fonts_path
            File.expand_path(
              "app/assets/fonts/decidim",
              Gem.loaded_specs["decidim-core"].full_gem_path
            )
          end
        end
      end
    end
  end
end
