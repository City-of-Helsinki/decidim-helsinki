# frozen_string_literal: true

module Decidim
  module Map
    module Provider
      module Geocoding
        # The geocoding utility class for Helsinki geocoding services
        class Helsinki < ::Decidim::Map::Geocoding
          DISTRICTS = [
            {
              name: { fi: "Ullanlinna", sv: "Ulrikasborg" },
              center: [24.949389752195597, 60.15937743034672]
            },
            {
              name: { fi: "Punavuori", sv: "Rödbergen" },
              center: [24.93767199004774, 60.16087967428461]
            },
            {
              name: { fi: "Tammisalo", sv: "Tammelund" },
              center: [25.06116460784951, 60.19153229577534]
            },
            {
              name: { fi: "Santahamina", sv: "Sandhamn" },
              center: [25.06738901832187, 60.15016344383851]
            },
            {
              name: { fi: "Vuosaari", sv: "Nordsjö" },
              center: [25.142086929875386, 60.22348546766297]
            },
            {
              name: { fi: "Katajanokka", sv: "Skatudden" },
              center: [24.97024183761138, 60.16764878017242]
            },
            {
              name: { fi: "Kaivopuisto", sv: "Brunnsparken" },
              center: [24.956562898588448, 60.15910914882776]
            },
            {
              name: { fi: "Hermanni", sv: "Hermanstad" },
              center: [24.967267536562368, 60.19553555253513]
            },
            {
              name: { fi: "Vanhakaupunki", sv: "Gammelstaden" },
              center: [24.980997347412938, 60.21484256789179]
            },
            {
              name: { fi: "Oulunkylä", sv: "Åggelby" },
              center: [24.95209989376845, 60.23381526720763]
            },
            {
              name: { fi: "Malmi", sv: "Malm" },
              center: [25.022154026843406, 60.245481050128696]
            },
            {
              name: { fi: "Haaga", sv: "Haga" },
              center: [24.88562877568868, 60.22242351201641]
            },
            {
              name: { fi: "Kaarela", sv: "Kårböle" },
              center: [24.88486025404869, 60.24790081021192]
            },
            {
              name: { fi: "Pakila", sv: "Baggböle" },
              center: [24.94375636520612, 60.242346421067246]
            },
            {
              name: { fi: "Tuomarinkylä", sv: "Domarby" },
              center: [24.94283998211677, 60.265292250923615]
            },
            {
              name: { fi: "Tapaninkylä", sv: "Staffansby" },
              center: [25.003739185707097, 60.265836412245214]
            },
            {
              name: { fi: "Kamppi", sv: "Kampen" },
              center: [24.93140480793743, 60.16754118134995]
            },
            {
              name: { fi: "Laakso", sv: "Dal" },
              center: [24.915024196264017, 60.192623585056275]
            },
            {
              name: { fi: "Kluuvi", sv: "Gloet" },
              center: [24.941976453816952, 60.17186265586831]
            },
            {
              name: { fi: "Ruskeasuo", sv: "Brunakärr" },
              center: [24.904464172134002, 60.203797012426925]
            },
            {
              name: { fi: "Sörnäinen", sv: "Sörnäs" },
              center: [24.967954152621832, 60.18689024989307]
            },
            {
              name: { fi: "Kallio", sv: "Berghäll" },
              center: [24.95265961320508, 60.1838454569264]
            },
            {
              name: { fi: "Etu-Töölö", sv: "Främre Tölö" },
              center: [24.92358901069816, 60.17206295380992]
            },
            {
              name: { fi: "Taka-Töölö", sv: "Bortre Tölö" },
              center: [24.919920244221196, 60.18781551962144]
            },
            {
              name: { fi: "Pasila", sv: "Böle" },
              center: [24.93374765278679, 60.204755601866694]
            },
            {
              name: { fi: "Mustikkamaa-Korkeasaari", sv: "Blåbärslandet-Högholmen" },
              center: [24.990042296218142, 60.17870789712147]
            },
            {
              name: { fi: "Kumpula", sv: "Gumtäkt" },
              center: [24.95661703216782, 60.204490692150785]
            },
            {
              name: { fi: "Koskela", sv: "Forsby" },
              center: [24.97015437224432, 60.21919352215524]
            },
            {
              name: { fi: "Länsisatama", sv: "Västra Hamnen" },
              center: [24.91867088602497, 60.16280056535149]
            },
            {
              name: { fi: "Viikki", sv: "Vik" },
              center: [25.00209870580221, 60.224850686731585]
            },
            {
              name: { fi: "Suurmetsä", sv: "Storskog" },
              center: [25.061129867251097, 60.271146287907264]
            },
            {
              name: { fi: "Kulosaari", sv: "Brändö" },
              center: [25.007002168393935, 60.18809027929995]
            },
            {
              name: { fi: "Pitäjänmäki", sv: "Sockenbacka" },
              center: [24.862014194952728, 60.22477023590215]
            },
            {
              name: { fi: "Mellunkylä", sv: "Mellungsby" },
              center: [25.07917874445913, 60.23622260655573]
            },
            {
              name: { fi: "Vartiosaari", sv: "Vårdö" },
              center: [25.078708866821206, 60.18144565761255]
            },
            {
              name: { fi: "Ultuna", sv: "Ultuna" },
              center: [25.193056344158883, 60.27213300580186]
            },
            {
              name: { fi: "Laajasalo", sv: "Degerö" },
              center: [25.054929553495473, 60.170701625286505]
            },
            {
              name: { fi: "Talosaari", sv: "Husö" },
              center: [25.185841401361863, 60.24424990655317]
            },
            {
              name: { fi: "Munkkiniemi", sv: "Munksnäs" },
              center: [24.861507764511895, 60.203308844177734]
            },
            {
              name: { fi: "Suomenlinna", sv: "Sveaborg" },
              center: [24.990262895305825, 60.14430264750583]
            },
            {
              name: { fi: "Ulkosaaret", sv: "Utöarna" },
              center: [25.018808137776862, 60.130771864841286]
            },
            {
              name: { fi: "Kaartinkaupunki", sv: "Gardesstaden" },
              center: [24.948247657522263, 60.1659961420725]
            },
            {
              name: { fi: "Lauttasaari", sv: "Drumsö" },
              center: [24.858146681462873, 60.16042769701977]
            },
            {
              name: { fi: "Suutarila", sv: "Skomakarböle" },
              center: [25.003250371338037, 60.27480056824577]
            },
            {
              name: { fi: "Vartiokylä", sv: "Botby" },
              center: [25.080638633915463, 60.21965168196473]
            },
            {
              name: { fi: "Konala", sv: "Kånala" },
              center: [24.84376442224016, 60.239328289703536]
            },
            {
              name: { fi: "Käpylä", sv: "Kottby" },
              center: [24.946927874408757, 60.213239241156394]
            },
            {
              name: { fi: "Pukinmäki", sv: "Bocksbacka" },
              center: [24.9873840358026, 60.24428956770915]
            },
            {
              name: { fi: "Östersundom", sv: "Östersundom" },
              center: [25.18153524270353, 60.251733769146504]
            },
            {
              name: { fi: "Aluemeri", sv: "Territorialhavet" },
              center: [24.994398384871747, 60.01259117862004]
            },
            {
              name: { fi: "Kruununhaka", sv: "Kronohagen" },
              center: [24.956548431664, 60.17172209744936]
            },
            {
              name: { fi: "Meilahti", sv: "Mejlans" },
              center: [24.903525661164434, 60.19148288595038]
            },
            {
              name: { fi: "Vallila", sv: "Vallgård" },
              center: [24.952742257135117, 60.19737811869121]
            },
            {
              name: { fi: "Villinki", sv: "Villinge" },
              center: [25.11759481672119, 60.15719387022072]
            },
            {
              name: { fi: "Eira", sv: "Eira" },
              center: [24.937948355517616, 60.156691468650486]
            },
            {
              name: { fi: "Toukola", sv: "Majstad" },
              center: [24.97487146147399, 60.208894513624735]
            },
            {
              name: { fi: "Herttoniemi", sv: "Hertonäs" },
              center: [25.04887636809123, 60.2048648087995]
            },
            {
              name: { fi: "Salmenkallio", sv: "Sundberg" },
              center: [25.171124635443675, 60.24635257047218]
            },
            {
              name: { fi: "Karhusaari", sv: "Björnsö" },
              center: [25.209580813096032, 60.25308415105047]
            },
            {
              name: { fi: "Alppiharju", sv: "Åshöjden" },
              center: [24.948957229279976, 60.18985239591177]
            }
          ].freeze

          # @see Decidim::Map::Geocoding#handle
          def handle
            @handle ||= :hki_servicemap
          end

          # @see Decidim::Map::Geocoding#search
          def search(query, options = {})
            query = Geocoder::Query.new(query, options) unless query.is_a?(Geocoder::Query)
            language = locale

            # Default the language to "fi" because otherwise the default would
            # be "en" as defined by the Geocoder default configurations. The
            # "en" language searches seemed to have problems with genuine
            # addresses which worked fine with "fi".
            language = "fi" if language != "sv"

            results = geocoder_lookup.search(query.text, options.merge(language: language))
            return results if results.present?
            return results if query.reverse_geocode?

            # Finally, perform a secondary search in the alternative language
            # (i.e. Finnish for Swedish original language, and vice versa). This
            # will serve the users better as especially Swedish speaking users
            # could be searching with Finnish place names.
            if language == "sv"
              geocoder_lookup.search(query.text, options.merge(language: "fi"))
            elsif language == "fi"
              geocoder_lookup.search(query.text, options.merge(language: "sv"))
            else
              results
            end
          end

          # @see Decidim::Map::Geocoding#coordinates
          def coordinates(address, options = {})
            results = search(address, options)
            return if results.empty?

            results.first.coordinates
          end

          # @see Decidim::Map::Geocoding#address
          def address(coordinates, options = {})
            results = search(coordinates, options)
            return if results.empty?

            results.sort! do |result1, result2|
              dist1 = Geocoder::Calculations.distance_between(
                result1.coordinates,
                coordinates
              )
              dist2 = Geocoder::Calculations.distance_between(
                result2.coordinates,
                coordinates
              )
              dist1 <=> dist2
            end

            results.first.street_address
          end

          protected

          # @see Decidim::Map::Utility#configure!
          def configure!(config)
            @configuration = config.merge(
              http_headers: {
                "User-Agent" => "Decidim/#{Decidim.version} (#{Decidim.application_name})",
                "Referer" => organization.host
              }
            )
          end

          private

          def geocoder_lookup
            Geocoder::Lookup::HkiServicemap.new
          end
        end
      end
    end
  end
end
