# frozen_string_literal: true

module Helsinki
  # This class provides some utility methods for finding geocoordinates for
  # neighborhoods and the closest neighborhood for a geocoordinate pair. We need
  # this for the city neighborhood searches in the geocoding functionality. The
  # current versions of the service map APIs do not provide a general geocoding
  # API which would allow to search a city neighborhood by its full name or part
  # of its name.
  #
  # This utility provides these capabilities for the application for better
  # results in the geocoding searches. Especially the text search by a location
  # name is important because otherwise searches such as "Lauttasaari" or
  # "Kruununhaka" would provide no results.
  #
  # This data has been extracted from the `administrative_division` geography
  # API endpoint in the service map APIs and the center points are calculated as
  # average center points from the area geography.
  class NeighborhoodSearch
    # Data source:
    # https://dev.hel.fi/apis/service-map-backend-api
    #
    # Terms of use:
    # https://hel.fi/palvelukarttaws/restpages/
    #
    # If you need to regenerate the data, fetch the updated list from the API
    # and turn it into an array with the following Ruby code:
    #   require "json"
    #   data = JSON.parse(data_string_from_api)
    #   neighborhoods = data["results"].map do |result|
    #     coordinates = result["boundary"]["coordinates"].flatten(2)
    #     {
    #       name: { fi: result["name"]["fi"], sv: result["name"]["sv"] },
    #       center: coordinates.transpose.map{ |c| (c.min + c.max).to_f / 2 }.reverse
    #     }
    #   end
    #
    #   # Standard Ruby:
    #   pp neighborhoods.inspect
    #   # With awesome_print gem:
    #   #require "awesome_print"
    #   #ap final, { index: false, indent: -2 }
    NEIGHBORHOODS = [
      {
        name: { fi: "Ullanlinna", sv: "Ulrikasborg" },
        center: [60.15565205254424, 24.948512533895908]
      },
      {
        name: { fi: "Punavuori", sv: "Rödbergen" },
        center: [60.16123059826518, 24.93614782721275]
      },
      {
        name: { fi: "Tammisalo", sv: "Tammelund" },
        center: [60.19165378185181, 25.061918090575773]
      },
      {
        name: { fi: "Santahamina", sv: "Sandhamn" },
        center: [60.138496454444166, 25.07306606545668]
      },
      {
        name: { fi: "Vuosaari", sv: "Nordsjö" },
        center: [60.203100164720595, 25.15379351415295]
      },
      {
        name: { fi: "Katajanokka", sv: "Skatudden" },
        center: [60.16657567956503, 24.981043820519332]
      },
      {
        name: { fi: "Kaivopuisto", sv: "Brunnsparken" },
        center: [60.157655390460235, 24.977640491606458]
      },
      {
        name: { fi: "Hermanni", sv: "Hermanstad" },
        center: [60.1949359465506, 24.9801234191563]
      },
      {
        name: { fi: "Vanhakaupunki", sv: "Gammelstaden" },
        center: [60.21387655808137, 24.97933721340512]
      },
      {
        name: { fi: "Oulunkylä", sv: "Åggelby" },
        center: [60.22974876624084, 24.944683846862944]
      },
      {
        name: { fi: "Malmi", sv: "Malm" },
        center: [60.24715710441501, 25.025697475865535]
      },
      {
        name: { fi: "Haaga", sv: "Haga" },
        center: [60.21846806571238, 24.890637626983928]
      },
      {
        name: { fi: "Kaarela", sv: "Kårböle" },
        center: [60.25182179739339, 24.873991019646766]
      },
      {
        name: { fi: "Pakila", sv: "Baggböle" },
        center: [60.243114617273505, 24.944089707596948]
      },
      {
        name: { fi: "Tuomarinkylä", sv: "Domarby" },
        center: [60.26167501601971, 24.938131726810244]
      },
      {
        name: { fi: "Tapaninkylä", sv: "Staffansby" },
        center: [60.26342274338081, 25.004690865945932]
      },
      {
        name: { fi: "Kamppi", sv: "Kampen" },
        center: [60.166274404397, 24.932054056817684]
      },
      {
        name: { fi: "Laakso", sv: "Dal" },
        center: [60.19353425841723, 24.91273591432765]
      },
      {
        name: { fi: "Kluuvi", sv: "Gloet" },
        center: [60.17388277343827, 24.941663111320032]
      },
      {
        name: { fi: "Ruskeasuo", sv: "Brunakärr" },
        center: [60.20243696874638, 24.904269158909337]
      },
      {
        name: { fi: "Sörnäinen", sv: "Sörnäs" },
        center: [60.18663207038734, 24.975768486865427]
      },
      {
        name: { fi: "Kallio", sv: "Berghäll" },
        center: [60.181934509707006, 24.947691964362946]
      },
      {
        name: { fi: "Etu-Töölö", sv: "Främre Tölö" },
        center: [60.17424094502894, 24.908602016975674]
      },
      {
        name: { fi: "Taka-Töölö", sv: "Bortre Tölö" },
        center: [60.18440213938124, 24.917618340673606]
      },
      {
        name: { fi: "Pasila", sv: "Böle" },
        center: [60.205920386266946, 24.927629869293547]
      },
      {
        name: { fi: "Mustikkamaa-Korkeasaari", sv: "Blåbärslandet-Högholmen" },
        center: [60.17730698953706, 24.99026645870717]
      },
      {
        name: { fi: "Kumpula", sv: "Gumtäkt" },
        center: [60.208465546033466, 24.960662769669156]
      },
      {
        name: { fi: "Koskela", sv: "Forsby" },
        center: [60.219360095768515, 24.96925723129179]
      },
      {
        name: { fi: "Länsisatama", sv: "Västra Hamnen" },
        center: [60.15796349529796, 24.916872844128733]
      },
      {
        name: { fi: "Viikki", sv: "Vik" },
        center: [60.217271083819654, 25.014880039180056]
      },
      {
        name: { fi: "Suurmetsä", sv: "Storskog" },
        center: [60.26743088977428, 25.06050643701446]
      },
      {
        name: { fi: "Kulosaari", sv: "Brändö" },
        center: [60.18958567264664, 25.005017000581525]
      },
      {
        name: { fi: "Pitäjänmäki", sv: "Sockenbacka" },
        center: [60.220626183178936, 24.860980701604632]
      },
      {
        name: { fi: "Mellunkylä", sv: "Mellungsby" },
        center: [60.236217070626715, 25.086318107171863]
      },
      {
        name: { fi: "Vartiosaari", sv: "Vårdö" },
        center: [60.181054684936285, 25.08734857805002]
      },
      {
        name: { fi: "Ultuna", sv: "Ultuna" },
        center: [60.27957703214793, 25.19812005779334]
      },
      {
        name: { fi: "Laajasalo", sv: "Degerö" },
        center: [60.17074557219382, 25.054119633131496]
      },
      {
        name: { fi: "Talosaari", sv: "Husö" },
        center: [60.238151525781305, 25.20341234611761]
      },
      {
        name: { fi: "Munkkiniemi", sv: "Munksnäs" },
        center: [60.19469167540729, 24.867095208923356]
      },
      {
        name: { fi: "Suomenlinna", sv: "Sveaborg" },
        center: [60.13827399620668, 24.99093742300046]
      },
      {
        name: { fi: "Ulkosaaret", sv: "Utöarna" },
        center: [60.11238523917992, 25.00117180505097]
      },
      {
        name: { fi: "Kaartinkaupunki", sv: "Gardesstaden" },
        center: [60.1655071938091, 24.949627470241637]
      },
      {
        name: { fi: "Lauttasaari", sv: "Drumsö" },
        center: [60.15870206267908, 24.867622941638505]
      },
      {
        name: { fi: "Suutarila", sv: "Skomakarböle" },
        center: [60.276893362550794, 25.0079869723467]
      },
      {
        name: { fi: "Vartiokylä", sv: "Botby" },
        center: [60.21173900184482, 25.083836394427784]
      },
      {
        name: { fi: "Konala", sv: "Kånala" },
        center: [60.24212530138334, 24.8487287228038]
      },
      {
        name: { fi: "Käpylä", sv: "Kottby" },
        center: [60.214063197862686, 24.948633900843525]
      },
      {
        name: { fi: "Pukinmäki", sv: "Bocksbacka" },
        center: [60.24271449710962, 24.987155648246585]
      },
      {
        name: { fi: "Östersundom", sv: "Östersundom" },
        center: [60.25963950752978, 25.19806690993877]
      },
      {
        name: { fi: "Aluemeri", sv: "Territorialhavet" },
        center: [60.0066404612168, 25.013602404952206]
      },
      {
        name: { fi: "Kruununhaka", sv: "Kronohagen" },
        center: [60.17264397421671, 24.96448681468576]
      },
      {
        name: { fi: "Meilahti", sv: "Mejlans" },
        center: [60.18478267080642, 24.892538759966207]
      },
      {
        name: { fi: "Vallila", sv: "Vallgård" },
        center: [60.195198192038475, 24.950540014849487]
      },
      {
        name: { fi: "Villinki", sv: "Villinge" },
        center: [60.159123740328205, 25.12632534378373]
      },
      {
        name: { fi: "Eira", sv: "Eira" },
        center: [60.15559286394001, 24.93852412811197]
      },
      {
        name: { fi: "Toukola", sv: "Majstad" },
        center: [60.205462620239715, 24.98076384920286]
      },
      {
        name: { fi: "Herttoniemi", sv: "Hertonäs" },
        center: [60.20121009688577, 25.041643743700824]
      },
      {
        name: { fi: "Salmenkallio", sv: "Sundberg" },
        center: [60.238562606479924, 25.16883516362379]
      },
      {
        name: { fi: "Karhusaari", sv: "Björnsö" },
        center: [60.24989555428981, 25.22031865160261]
      },
      {
        name: { fi: "Alppiharju", sv: "Åshöjden" },
        center: [60.19046994814737, 24.94841978116971]
      }
    ].freeze

    # Stores an array of the Finnish names for faster searches.
    #
    # @return [Array<String>] The array of the "fi" names.
    def self.names_fi
      @names_fi ||= NEIGHBORHOODS.map { |val| val[:name][:fi] }
    end

    # Stores an array of the Swedish names for faster searches.
    #
    # @return [Array<String>] The array of the "sv" names.
    def self.names_sv
      @names_sv ||= NEIGHBORHOODS.map { |val| val[:name][:sv] }
    end

    # Stores an array of the center coordinates for faster searches.
    #
    # @return [Array<String>] The array of the center coordinates.
    def self.centers
      @centers ||= NEIGHBORHOODS.map { |val| val[:center] }
    end

    # Finds an exact match result by searching with the exact name in the
    # results array.
    #
    # @param name [String] The name to find.
    # @param options [Hash] Options
    # @option options [Symbol] :locale The locale for the search, :fi or :sv.
    # @return [Hash, nil ] The result hash with the given exact name or nil if
    #   no result is found.
    def self.find(name, locale: :fi)
      ind = case locale
            when :sv
              names_sv.find_index(name)
            else
              names_fi.find_index(name)
            end

      NEIGHBORHOODS[ind] if ind
    end

    # Searches for the best match result by grepping the list of the names with
    # the given search. Searches e.g. "laUTTa" would return the result hash for
    # "Lauttasaari".
    #
    # @param query [String] The query for the search.
    # @param options [Hash] Options
    # @option options [Symbol] :locale The locale for the search, :fi or :sv.
    #   Default is :fi.
    # @return [Hash, nil] The best matching result hash for the search result or
    #   nil if no result is found.
    def self.search(query, locale: :fi)
      return unless query.is_a?(String)
      return if query.strip.empty?

      results = case locale
                when :sv
                  names_sv.grep(/#{query}/i)
                else
                  names_fi.grep(/#{query}/i)
                end

      find(results.first)
    end

    # Turns a given string for a neighborhood search to the corresponding best
    # matching coordinates for that result.
    #
    # @param query [String] The query for the search.
    # @param options [Hash] Options
    # @option options [Symbol] :locale The locale for the search, :fi or :sv.
    #   Default is :fi.
    # @option options [Boolean] :exact A boolean indicating whether the search
    #   is an exact match search instead of string grepping.
    # @return [Hash, nil] The best matching result hash for the search result or
    #   nil if no result is found.
    def self.coordinates(query, locale: :fi, exact: false)
      result = if exact
                 find(query.capitalize, locale: locale)
               else
                 search(query, locale: locale)
               end
      return unless result

      result[:center]
    end

    # Finds the closest area for the given coordinate array (latitude,
    # longitude).
    #
    # @param coordinates [Array(Float, Float)] The set of coordinates (latitude,
    #   longitude) to search for.
    # @return [Hash] The closest match for the coordinates. Will always return
    #   the best match, even if the searched coordinates are on the other side
    #   of the world.
    def self.reverse(coordinates)
      distances = NEIGHBORHOODS.map do |neighborhood|
        Geocoder::Calculations.distance_between(
          neighborhood[:center],
          coordinates
        )
      end

      NEIGHBORHOODS[distances.index(distances.min)]
    end

    # Finds the name for the neighborhood closest to the given matching set of
    # coordinates.
    #
    # @param coordinates [Array(Float, Float)] The set of coordinates (latitude,
    #   longitude) to search for.
    # @param options [Hash] Options
    # @option options [Symbol] :locale The locale for the name, :fi or :sv.
    #   Default is :fi.
    # @return [String] The name for the closest match for the coordinates.
    def self.name(coordinates, locale: :fi)
      result = reverse(coordinates)
      result[:name][locale]
    end
  end
end
