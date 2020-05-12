# frozen_string_literal: true

module Helsinki
  # The purpose of this class is to provide utilities for managing the data
  # migration process for the "new" way of doing things in 2020. In the past all
  # the city areas had their own processes but in the future this is no longer
  # the case.
  #
  # This is supposed to be one off migration utility but it is "detached" to
  # its own class due to its excessive verbosity.
  module Migration
    class SingleProcessOmastadi < SingleProcessBase
      PROCESS_SCOPE_MAP = {
        "omastadi-etelainen" => "ETELÄ",
        "omastadi-itainen" => "ITÄINEN",
        "omastadi-kaakkoinen" => "KAAKKOINEN",
        "omastadi-keskinen" => "KESKINEN",
        "omastadi-koillinen" => "KOILLINEN",
        "omastadi-kokohelsinki" => "KOKOHELSINKI",
        "omastadi-lantinen" => "LÄNTINEN",
        "omastadi-pohjoinen" => "POHJOINEN"
      }.freeze

      def migrate
        # Create the new components
        meetings_component = create_meetings_component
        proposals_component = create_proposals_component
        plans_component = create_plans_component
        accountability_component = create_accountability_component

        # Initialize plan mover
        plan_mover = Decidim::Plans::PlanMover.new(plans_component)

        index = 0
        PROCESS_SCOPE_MAP.each do |process_slug, scope_code|
          process = Decidim::ParticipatoryProcess.find_by(slug: process_slug)
          scope = Decidim::Scope.find_by(code: scope_code)

          raise "No process found: #{process_slug}" unless process
          raise "No scope found: #{scope_code}" unless scope

          fix_categories(process)

          process_followers_to_scope_interests(process, scope)

          # Move attachments to the combined process
          transfer_attachments(process, combined_process)

          # Move meetings to the new component
          move_items_to_other_component(
            {
              process: process,
              manifest_name: "meetings",
              items_class: Decidim::Meetings::Meeting,
              items_slug: "meetings"
            },
            component: meetings_component,
            scope: scope
          )

          # Move proposals to the new component
          move_items_to_other_component(
            {
              process: process,
              manifest_name: "proposals",
              items_class: Decidim::Proposals::Proposal,
              items_slug: "proposals"
            },
            component: proposals_component,
            scope: scope
          )

          # Move plans to the new component
          move_plans_to_other_component(process, plan_mover, scope)

          # Move budgets components to the new process
          move_budgets_to_new_process(process, combined_process, 1000 + index, scope)

          # Move accountability results to the new component
          move_items_to_other_component(
            {
              process: process,
              manifest_name: "accountability",
              items_class: Decidim::Accountability::Result,
              items_slug: "results"
            },
            component: accountability_component,
            scope: scope
          )

          # Redirect the process
          set_redirection(
            "/processes/#{process.slug}",
            "/processes/#{combined_process.slug}"
          )

          process.destroy!
          index += 1
        end

        create_budgets_overview_page(create_budgets_overview_component)
        update_budgets_step_settings

        combined_process.publish!

        # Redirect the old process group URL to the combined process and
        # remove the process group.
        group = Decidim::ParticipatoryProcessGroup.find_by(
          "name->>'fi' =?", "Helsingin osallistuva budjetointi"
        )
        set_redirection(
          "/processes_groups/#{group.id}",
          "/processes/#{combined_process.slug}"
        )
        group.destroy!

        # Redirect the accountability combination page
        set_redirection(
          "/results/helsingin-osallistuva-budjetointi",
          "/processes/#{combined_process.slug}/f/#{accountability_component.id}/"
        )
      end

      private

      def fix_categories(process)
        process.categories.each do |cat|
          cat_name = cat.name["fi"]
          if cat_name == "Oppinen ja osaaminen"
            cat.name["fi"] = "Oppiminen ja osaaminen"
            cat.save!
          elsif cat_name == "Puisto ja luonto"
            cat.name["fi"] = "Puistot ja luonto"
            cat.save!
          end
        end
      end

      def create_combined_process
        combined_process = Decidim::ParticipatoryProcess.find_by(slug: "osbu-2019")
        return combined_process if combined_process

        base_path = File.expand_path(File.join(Rails.root, "app", "assets", "images", "helsinki", "osbu-2019"))

        hero_image = Pathname.new("#{base_path}/hero.jpg").open
        banner_image = Pathname.new("#{base_path}/banner.png").open
        main_scope = Decidim::Scope.find_by(code: "SUURPIIRI")

        combined_process = Decidim::ParticipatoryProcess.create!(
          organization: Decidim::Organization.first,
          title: {
            "fi" => "Osallistuva budjetointi 2019-2020",
            "en" => "Participatory budjeting 2019-2020",
            "sv" => "Medborgarbudget 2019-2020"
          },
          subtitle: {
            "fi" => "OmaStadi on Helsingin tapa toteuttaa osallistuvaa budjetointia",
            "en" => "OmaStadi is Helsinki’s way of doing participatory budgeting.",
            "sv" => "OmaStadi är Helsingfors sätt att förverkliga medborgarbudget."
          },
          slug: "osbu-2019",
          description: {
            "fi" => [
              "<p>Mikä tekisi omasta asuinalueestasi toimivamman, viihtyisämmän ja hauskemman? Osallistuvassa budjetoinnissa kehitetään yhteistä kaupunkia neljässä vaiheessa.</p>",
              "<ol>",
              "<li>Ideointivaiheessa kuka tahansa voi tehdä parantamisehdotuksia Helsingin kaupungille.</li>",
              "<li>Suunnitelmavaiheessa ehdotuksista kehitetään yhdessä kaupunkilaisten ja kaupungin palvelujen asiantuntijoiden kanssa toteuttamiskelpoisia suunnitelmia.</li>",
              "<li>Kustannusarviovaiheessa kaupungin asiantuntijat tekevät yhteisesti kehitetyille suunnitelmille kustannusarviot.</li>",
              "<li>Äänestysvaiheessa suunnitelmia voivat äänestää kaikki 12-vuotta täyttäneet ja sitä vanhemmat helsinkiläiset.</li>",
              "</ol>",
              "<p>",
              "Osallistuvassa budjetoinnissa tavoitteena on ideoida ehdotuksia ja tehdä reiluja suunnitelmia, jotka hyödyttävät monia. ",
              "Ehdotusten jättäminen, suunnitelmien tekeminen ja äänestäminen tapahtuvat OmaStadi.hel.fi palvelussa.",
              "</p>",
              "<p>Kokonaisbudjetti on 4,4 milj. euroa ja se jakautuu suurpiirien kesken asukasluvun mukaan:</p>",
              "<ul>",
              "<li>",
              "Läntinen Helsinki: 613 200€",
              "<ul>",
              "<li><u>Reijola</u>: Laakso, Vanha Ruskeasuo, Pikku Huopalahti, Meilahti</li>",
              "<li><u>Munkkiniemi</u>: Niemenmäki, Munkkivuori, Talinranta, Vanha Munkkiniemi, Kuusisaari, Lehtisaari</li>",
              "<li><u>Haaga</u>: Etelä-Haaga, Kivihaka, Pohjois-Haaga, Lassila, Pikku Huopalahti</li>",
              "<li><u>Pitäjänmäki</u>: Tali, Pajamäki, Pitäjänmäen yritysalue, Reimarla, Marttila, Konala</li>",
              "<li><u>Kaarela</u>: Kannelmäki, Maununneva, Malminkartano, Hakuninmaa, Kuninkaantammi, Honkasuo</li>",
              "</ul>",
              "</li>",
              "<li>",
              "Kaakkoinen Helsinki: 288 390€",
              "<ul>",
              "<li><u>Kulosaari</u>: Mustikkamaa, Korkeasaari, Kulosaari</li>",
              "<li><u>Herttoniemi</u>: Länsi-Herttoniemi, Roihuvuori, Herttoniemen yritysalue, Herttoniemenranta</li>",
              "<li><u>Laajasalo</u>: Yliskylä, Jollas, Tullisaari, Kruunuvuorenranta, Hevossalmi</li>",
              "<li><u>Tammisalo</u></li>",
              "<li><u>Vartiosaari</u></li>",
              "<li><u>Villinki</u></li>",
              "<li><u>Santahamina</u></li>",
              "<li><u>Itäsaaret</u></li>",
              "</ul>",
              "</li>",
              "<li>",
              "Eteläinen Helsinki: 653 250€",
              "<ul>",
              "<li><u>Vironniemi</u>: Kruunuhaka, Kluuvi, Katajanokka</li>",
              "<li><u>Ullanlinna</u>: Kaartinkaupunki, Punavuori, Eira, Ullanlinna, Kaivopuisto, Hernesaari, Suomenlinna, Kamppi, Suomenlinna, Länsisaaret</li>",
              "<li><u>Kampinmalmi</u>: Kamppi, Etu-Töölö, Ruoholahti, Jätkäsaari, Lapinlahti, Taka-Töölö</li>",
              "<li><u>Lauttasaari</u>: Lauttasaari, Kotkavuori, Vattuniemi, Myllykallio, Koivusaari</li>",
              "</ul>",
              "</li>",
              "<li>",
              "Itäinen Helsinki: 639 650€",
              "<ul>",
              "<li><u>Vartiokylä</u>: Vartioharju, Puotila, Puotinharju, Myllypuro, Marjaniemi, Roihupellon teollisuusalue ja Itäkeskus</li>",
              "<li><u>Mellunkylä</u>: Kontula, Vesala; Mellunmäki, Kivikko ja Kurkimäki</li>",
              "<li><u>Vuosaari</u>: Keski-Vuosaari, Nordsjön kartano, Uutela, Meri-Rastila, Kallahti, Aurinkolahti, Rastila, Niinisaari ja Mustavuori</li>",
              "<li><u>Östersumdom</u>: Ultuna, Östersundom, Salmenkallio, Talosaari ja Karhusaari</li>",
              "</ul>",
              "</li>",
              "<li>",
              "Pohjoinen Helsinki: 241 860€",
              "<ul>",
              "<li><u>Maunula</u>: Pirkkola, Maunula, Metsälä, Maunulanpuisto</li>",
              "<li><u>Länsi-Pakila</u></li>",
              "<li><u>Tuomarinkylä</u>: Paloheinä, Torpparinmäki, Haltiala</li>",
              "<li><u>Oulunkylä</u>: Patola, Veräjämäki, Veräjälaakso</li>",
              "<li><u>Itä-Pakila</u>: Itä-Pakila, Tuomarinkartano</li>",
              "</ul>",
              "</li>",
              "<li>",
              "Keskinen Helsinki: 519 590€",
              "<ul>",
              "<li><u>Alppiharju</u>: Alppila ja Harju</li>",
              "<li><u>Kallio</u>: Hanasaari, Kalasatama, Linjat, Siltasaari, Sörnäinen, Sompasaari, Torkkelinmäki ja Vilhonvuori</li>",
              "<li><u>Pasila</u>: Itä-Pasila, Keski-Pasila Länsi-Pasila ja Pohjois-Pasila</li>",
              "<li><u>Vallila</u>: Hermanni, Hermanninmäki, Hermanninranta, Konepaja ja Kyläsaari</li>",
              "<li><u>Vanhakaupunki</u>: Arabianranta, Koskela, Kumpula, Käpylä ja Toukola</li>",
              "</ul>",
              "</li>",
              "<li>",
              "Koillinen Helsinki: 559 680€",
              "<ul>",
              "<li><u>Latokartano</u>: Viikinranta, Latokartano, Viikin tiedepuisto, Viikinmäki, Pihlajamäki, Pihlajisto</li>",
              "<li><u>Pukinmäki</u></li>",
              "<li><u>Malmi</u>: Ylä-Malmi, Ala-Malmi, Tattariharju, Malmin lentokenttä, Tapaninvainio, Tapanila</li>",
              "<li><u>Suutarila</u>: Siltamäki, Töyrynnummi</li>",
              "<li><u>Puistola</u>: Tapulikaupunki, Puistola, Heikinlaakso, Tattarisuo, Alppikylä</li>",
              "<li><u>Jakomäki</u></li>",
              "</ul>",
              "</li>",
              "<li>Koko Helsinki: 880 000€ (koko Helsingin yhteiset hankkeet, 20 prosenttia summasta)</li>",
              "</ul>"
            ].join,
            "en" => [
              "<p>",
              "What would make Helsinki more functional, pleasant and fun? You are not required to have accurate cost information in the proposal phase. ",
              "The ideas are later developed into feasible plans by the residents and experts from the City services. The experts will create cost estimates for the plans. ",
              "These plans are then voted on. The purpose of OmaStadi is to draw up proposals and make plans that are equal for all and benefit everyone. ",
              "The district’s proposals can be voted on by everyone aged 12 or over. ",
              "Submitting proposals, developing plans and voting are all done in the OmaStadi.hel.fi service.",
              "</p>",
              "<p>The total budget is 4.4 million euros and it is divided between the major districts in proportion to population:</p>",
              "<ul>",
              "<li>",
              "Western Helsinki: €613,200",
              "<ul>",
              "<li><u>Reijola</u>: Laakso, Vanha Ruskeasuo, Pikku Huopalahti, Meilahti</li>",
              "<li><u>Munkkiniemi</u>: Niemenmäki, Munkkivuori, Talinranta, Vanha Munkkiniemi, Kuusisaari, Lehtisaari</li>",
              "<li><u>Haaga</u>: Etelä-Haaga, Kivihaka, Pohjois-Haaga, Lassila, Pikku Huopalahti</li>",
              "<li><u>Pitäjänmäki</u>: Tali, Pajamäki, Pitäjänmäki business zone, Reimarla, Marttila, Konala</li>",
              "<li><u>Kaarela</u>: Kannelmäki, Maununneva, Malminkartano, Hakuninmaa, Kuninkaantammi, Honkasuo</li>",
              "</ul>",
              "</li>",
              "<li>",
              "Southeastern Helsinki: €288,390",
              "<ul>",
              "<li><u>Kulosaari</u>: Mustikkamaa, Korkeasaari, Kulosaari</li>",
              "<li><u>Herttoniemi</u>: Länsi-Herttoniemi, Roihuvuori, Herttoniemi business zone, Herttonimenranta, Tammisalo</li>",
              "<li><u>Laajasalo</u>: Vartiosaari, Yliskylä, Jollas, Tullisaari, Kruunuvuorenranta, Hevossalmi, Villinki, Santahamina, Itäsaaret</li>",
              "<li><u>Tammisalo</u></li>",
              "<li><u>Vartiosaari</u></li>",
              "<li><u>Villinki</u></li>",
              "<li><u>Santahamina</u></li>",
              "<li><u>Itäsaaret</u></li>",
              "</ul>",
              "</li>",
              "<li>",
              "Southern Helsinki: €653,250",
              "<ul>",
              "<li><u>Vironniemi</u>: Kruunuhaka, Kluuvi, Katajanokka</li>",
              "<li><u>Ullanlinna</u>: Kaartinkaupunki, Punavuori, Eira, Ullanlinna, Kaivopuisto, Hernesaari, Suomenlinna, Kamppi, Suomenlinna, Länsisaaret</li>",
              "<li><u>Kampinmalmi</u>: Kamppi, Etu-Töölö, Ruoholahti, Jätkäsaari, Lapinlahti, Taka-Töölö</li>",
              "<li><u>Lauttasaari</u>: Lauttasaari, Kotkavuori, Vattuniemi, Myllykallio, Koivusaari</li>",
              "</ul>",
              "</li>",
              "<li>",
              "Eastern Helsinki: €639,650",
              "<ul>",
              "<li><u>Vartiokylä</u>: Vartioharju, Puotila, Puotinharju, Myllypuro, Marjaniemi, Roihupelto industrial zone and Itäkeskus</li>",
              "<li><u>Mellunkylä</u>: Kontula, Vesala; Mellunmäki, Kivikko and Kurkimäki</li>",
              "<li><u>Vuosaari</u>: Keski-Vuosaari, Nordsjö manor, Uutela, Meri-Rastila, Kallahti, Aurinkolahti, Rastila, Niinisaari and Mustavuori</li>",
              "<li><u>Östersumdom</u>: Ultuna, Östersundom, Salmenkallio, Talosaari and Karhusaari</li>",
              "</ul>",
              "</li>",
              "<li>",
              "Northern Helsinki: €241,860",
              "<ul>",
              "<li><u>Maunula</u>: Pirkkola, Maunula, Metsälä, Maunulanpuisto</li>",
              "<li><u>Länsi-Pakila</u></li>",
              "<li><u>Tuomarinkylä</u>: Paloheinä, Torpparinmäki, Haltiala</li>",
              "<li><u>Oulunkylä</u>: Patola, Veräjämäki, Veräjälaakso</li>",
              "<li><u>Itä-Pakila</u>: Itä-Pakila, Tuomarinkartano</li>",
              "</ul>",
              "</li>",
              "<li>",
              "Central Helsinki: €519,590",
              "<ul>",
              "<li><u>Alppiharju</u>: Alppila, Harju</li>",
              "<li><u>Kallio</u>: Hanasaari, Kalasatama, the Linja streets, Siltasaari, Sörnäinen, Sompasaari, Torkkelinmäki, Vilhonvuori</li>",
              "<li><u>Pasila</u>: Itä-Pasila, Keski-Pasila Länsi-Pasila, Pohjois-Pasila</li>",
              "<li><u>Vallila</u>: Hermanni, Hermanninmäki, Hermanninranta, Konepaja, Kyläsaari</li>",
              "<li><u>Vanhakaupunki</u>: Arabianranta, Koskela, Kumpula, Käpylä, Toukola</li>",
              "</ul>",
              "</li>",
              "<li>",
              "Northeastern Helsinki: €559,680",
              "<ul>",
              "<li><u>Latokartano</u>: Viikinranta, Latokartano, Viikki science park, Viikinmäki, Pihlajamäki</li>",
              "<li><u>Pukinmäki</u></li>",
              "<li><u>Malmi</u>: Ylä-Malmi, Ala-Malmi, Tattariharju, Malmi airport, Tapaninvainio, Tapanila</li>",
              "<li><u>Suutarila</u>: Suutarila, Siltamäki, Töyrynnummi</li>",
              "<li><u>Puistola</u>: Tapulikaupunki, Puistola, Heikinlaakso, Tattarisuo, Alppikylä</li>",
              "<li><u>Jakomäki</u></li>",
              "</ul>",
              "</li>",
              "<li>All of Helsinki : €880,000 (projects that concern the entire city, twenty per cent of the sum)</li>",
              "</ul>"
            ].join,
            "sv" => [
              "<p>",
              "Vad skulle göra att Helsingfors i stort fungerar bättre och blir trivsammare och roligare? I förslagsskedet behöver du inte veta i detalj hur mycket något kostar. ",
              "Senare vidareutvecklar stadsborna tillsammans med experter inom stadens tjänster idéerna till genomförbara planer. Experterna beräknar priset för planerna. ",
              "Dessa planer går sedan till omröstning. I OmaStadi är målet att göra förslag och rättvisa planer som gagnar många. ",
              "Alla Helsingforsbor som fyllt minst 12 år kan rösta på förslagen i sitt område. Förslagen, planerna och omröstningen sker i webbtjänsten OmaStadi.hel.fi.",
              "</p>",
              "<p>Budgeten uppgår till totalt 4,4 miljoner euro och fördelas mellan stordistrikten enligt invånarantal:</p>",
              "<ul>",
              "<li>",
              "Västra Helsingfors: 613 200€",
              "<ul>",
              "<li><u>Grejus</u>: Dal, Gamla Brunakärr, Lillhoplax, Mejlans</li>",
              "<li><u>Munksnäs</u>: Näshöjden, Munkshöjden, Talistranden, Gamla Munksnäs, Granö, Lövö</li>",
              "<li><u>Haga</u>: Södra Haga, Stenhagen, Norra Haga, Lassas, Lillhoplax</li>",
              "<li><u>Sockenbacka</u>: Tali, Smedjebacka, Sockenbacka företagsområde, Reimars, Martas, Kånala</li>",
              "<li><u>Kårböle</u>: Gamlas, Magnuskärr, Malmgård, Håkansåker, Kungseken, Hongasmossa</li>",
              "</ul>",
              "</li>",
              "<li>",
              "Sydöstra Helsingfors: 288 390€",
              "<ul>",
              "<li><u>Brändö</u>: Blåbärslandet, Högholmen, Brändö</li>",
              "<li><u>Hertonäs</u>: Västra Hertonäs, Kasberget, Hertonäs företagsområde, Hertonäs strand</li>",
              "<li><u>Degerö</u>: Uppby, Jollas, Turholm, Kronobergsstranden, Hästnässundet</li>",
              "<li><u>Tammelund</u></li>",
              "<li><u>Vårdö</u></li>",
              "<li><u>Villinge</u></li>",
              "<li><u>Sandhamn</u></li>",
              "<li><u>Östra holmarna</u></li>",
              "</ul>",
              "</li>",
              "<li>",
              "Södra Helsingfors: 653 250€",
              "<ul>",
              "<li><u>Estnäs</u>: Kronohagen, Gloet, Skatudden</li>",
              "<li><u>Ulrikasborg</u>: Gardesstaden, Rödbergen, Eira, Ulrikasborg, Brunnsparken, Ärtholmen, Sveaborg, Kampen, Västra holmarna</li>",
              "<li><u>Kampmalmen</u>: Kampen, Främre Tölö, Gräsviken, Busholmen, Lappviken, Bortre Tölö</li>",
              "<li><u>Drumsö</u>: Drumsö, Örnberget, Hallonnäs, Kvarnberget, Björkholmen</li>",
              "</ul>",
              "</li>",
              "<li>",
              "Östra Helsingfors: 639 650€",
              "<ul>",
              "<li><u>Botby</u>: Botbyåsen, Botby gård, Botbyhöjden, Kvarnbäcken, Marudd, Kasåkerns företagsområde och Östra centrum</li>",
              "<li><u>Mellungsby</u>: Gårdsbacka, Ärvings, Mellungsbacka, Stensböle och Tranbacka</li>",
              "<li><u>Nordsjö</u>: Mellersta Nordsjö, Nordsjö gård, Nybondas, Havsrastböle, Kallvik, Solvik, Rastböle, Bastö och Svarta backen</li>",
              "<li><u>Östersundom</u>: Ultuna, Östersundom, Sundberg, Husö och Björnsö</li>",
              "</ul>",
              "</li>",
              "<li>",
              "Norra Helsingfors: 241 860€",
              "<ul>",
              "<li><u>Månsas</u>: Britas, Månsas, Krämertsskog, Månsasparken</li>",
              "<li><u>Västra Baggböle</u></li>",
              "<li><u>Domarby</u>: Svedängen, Torparbacken, Tomtbacka</li>",
              "<li><u>Åggelby</u>: Parkstad, Grindbacka, Grinddal</li>",
              "<li><u>Östra Baggböle</u>: Östra Baggböle, Domargård</li>",
              "</ul>",
              "</li>",
              "<li>",
              "Centrala Helsingfors: 519 590€",
              "<ul>",
              "<li><u>Åshöjden</u>: Ås, Alphyddan</li>",
              "<li><u>Berghäll</u>: Sörnäs, Vilhelmsberg, Fiskehamnen, Sumparn, Hanaholmen, Broholmen, Linjerna, Torkelsbacken</li>",
              "<li><u>Böle</u>: Västra Böle, Norra Böle, Östra Böle, Mellersta Böle</li>",
              "<li><u>Vallgård</u>: Hermanstad, Byholmen, Hermanstadstranden</li>",
              "<li><u>Gammelstaden</u>: Majstad, Arabiastraden, Gumtäkt, Kottby, Forsby, Gammelstaden</li>",
              "</ul>",
              "</li>",
              "<li>",
              "Nordöstra Helsingfors: 559 680€",
              "<ul>",
              "<li><u>Ladugården</u>: Viksstrand, Ladugården, Viks vetenskapspark, Viksbacka, Rönnbacka</li>",
              "<li><u>Bocksbacka</u></li>",
              "<li><u>Malm</u>: Övre Malm, Nedre Malm, Tattaråsen, Malms flygplats, Staffansslätten, Mosabacka</li>",
              "<li><u>Skomakarböle</u>: Skomakarböle, Brobacka, Lidamalmen</li>",
              "<li><u>Parkstad</u>: Stapelstaden, Parkstad, Henriksdal, Tattarmossen, Alpbyn</li>",
              "<li><u>Jakobacka</u></li>",
              "</ul>",
              "</li>",
              "<li>Hela Helsingfors: 880 000€ (projekt som är gemensamma för hela Helsingfors, 20 procent av beloppet)</li>",
              "</ul>"
            ].join
          },
          short_description: {
            "fi" => [
              "Helsinki avaa vuosittain 4,4 miljoonaa euroa omaa budjettiaan ja kaupunkilaiset saavat ehdottaa ja päättää siitä, miten se käytetään."
            ].join,
            "en" => [
              "Here, you can submit proposals between 15 November and 9 December 2018 that are not local but concern the entire city of Helsinki. ",
              "Every year, the City of Helsinki will allocate €4.4 million of its budget to be decided upon by the city’s residents. ",
              "How would you like this money to be spent?"
            ].join,
            "sv" => [
              "Här kan du under perioden 15.11–9.12.2018 göra förslag som inte är lokala utan gäller hela Helsingfors. ",
              "Helsingfors avsätter varje år 4,4 miljoner euro ur sin egen budget och stadsborna får göra förslag på och bestämma hur summan ska användas. ",
              "Hur skulle du önska att pengarna används?"
            ].join
          },
          hero_image: hero_image,
          banner_image: banner_image,
          promoted: false,
          scopes_enabled: true,
          scope: main_scope,
          private_space: false,
          developer_group: {},
          local_area: {},
          target: {},
          participatory_scope: {},
          participatory_structure: {},
          meta_scope: {},
          start_date: Date.new(2018, 10, 25),
          end_date: Date.new(2019, 12, 31)
        )

        # Create the steps
        combined_process.steps.create!(
          position: 0,
          title: {
            "fi" => "Ennakkotiedotus ja työpajat",
            "en" => "Advance information and workshopsIntroduction",
            "sv" => "Förhandsinformation och verkstäder"
          },
          description: {
            "fi" => [
              "<p>",
              "Ehdotusten ideointi käynnistyy jo hyvissä ajoin ennen kuin ehdotuksia voi jättää OmaStadi.hel.fi palveluun. Voit ideoida ehdotuksia yksin, kaksin tai porukalla. ",
              "Myös stadiluotsit järjestävät tilaisuuksia ehdotusten ideoimiseksi. ",
              "Tilaisuuksissa pääset pelaamaan OmaStadi peliä, jota pelaamalla tutustut helposti ja hauskasti osallistuvan budjetoinnin vaiheisiin ja reunaehtoihin. ",
              "Pelin pelaaminen kestää noin tunnin ja sen päätteeksi syntyy OmaStadi ehdotus. Löydät tiedot tilaisuuksista Tapahtumat-osiosta.",
              "</p>"
            ].join,
            "en" => [
              "<p>",
              "You may begin to develop ideas well in advance before you can submit your proposals via the OmaStadi.hel.fi service. ",
              "Ideas can be developed on your own, with a friend or in a group. Borough liaisons also arrange events where you can develop your proposal ideas. ",
              "At these events, you’ll have the chance to play the OmaStadi game, which is a fun and effortless way of learning more about the steps and framework of ",
              "participatory budgeting. At the end of the one hour game session, you will have created your own OmaStadi proposal! ",
              "More information about the events can be found in the Events section.",
              "</p>"
            ].join,
            "sv" => [
              "<p>",
              "Förslagen börjar utformas i god tid innan de läggs fram i OmaStadi.hel.fi. Du kan utforma dina förslag ensam, i par eller i grupp. ",
              "Också stadslotsarna ordnar evenemang där idéer utformas. ",
              "Under dessa evenemang får du spela OmaStadi-spelet, vilket låter dig förkovra dig i den deltagande budgeteringens olika skeden och villkor på ett enkelt och ",
              "roligt sätt. Spelet tar omkring en timme i anspråk och resulterar i ett OmaStadi-förslag. ",
              "Information om evenemangen finns på webbplatsen under avdelningen Evenemang.",
              "</p>"
            ].join
          },
          start_date: Date.new(2018, 10, 25),
          end_date: Date.new(2018, 11, 14),
          active: false
        )
        combined_process.steps.create!(
          position: 1,
          title: {
            "fi" => "Ehdottaminen",
            "en" => "Proposals",
            "sv" => "Ge förslag"
          },
          description: {
            "fi" => [
              "<p>",
              "Voit tehdä ehdotuksen siitä, miten kaupunginlaajuisille hankkeille varatut 880 000 euroa käytetään. ",
              "Voit ideoida ehdotuksia yksin, isommalla porukalla tai osallistumalla stadiluotsien järjestämiin tilaisuuksiin. ",
              "OmaStadi.hel.fi palvelussa ehdotuksia voi kommentoida ja suositella toisille. ",
              "Kaupungin palvelut arvioivat ehdotuksia suhteessa osallistuvan budjetoinnin reunaehtoihin. ",
              "Jokainen ehdotus luetaan ja merkitään joko sellaiseksi, että se täyttää annetut reunaehdot tai ei täytä niitä. ",
              "Jos ehdotus ei täytä reunaehtoja, annetaan sille myös perustelut omastadi.hel.fi palvelussa.",
              "</p>"
            ].join,
            "en" => [
              "<p>",
              "You can submit a proposal for how a portion of the €880000 allocated to entire Helsinki should be spent. ",
              "You can develop ideas on your own, in a larger group or by participating in the events arranged by borough liaisons. ",
              "You can comment on and recommend proposals in the OmaStadi.hel.fi service. ",
              "The City services will evaluate the proposals within the framework of participatory budgeting. ",
              "Each proposal is reviewed and marked according to whether it fits into the framework or not. ",
              "If a proposal does not fit into the framework, this will be explained in the omastadi.hel.fi service.",
              "</p>"
            ].join,
            "sv" => [
              "<p>",
              "Du kan lägga fram förslag på hur en del av de 880 000 euro som reserverats för hela Helsingfors ska användas. ",
              "Du kan utarbeta dina förslag ensam, i en större grupp eller genom att delta i de evenemang som stadslotsarna ordnar. ",
              "I tjänsten OmaStadi.hel.fi kan förslagen kommenteras och rekommenderas för andra. ",
              "Stadens tjänster utvärderar förslagen i förhållande till ramvillkoren för den deltagande budgeteringen. ",
              "Alla förslag läses och för varje markeras huruvida det uppfyller de givna villkoren eller inte. ",
              "Om ett förslag inte uppfyller ramvillkoren ges en motivering till detta på OmaStadi.hel.fi.",
              "</p>"
            ].join
          },
          start_date: Date.new(2018, 11, 15),
          end_date: Date.new(2018, 12, 9),
          active: false
        )
        combined_process.steps.create!(
          position: 2,
          title: {
            "fi" => "Ehdotusten arvionti",
            "en" => "Evaluation of the proposals",
            "sv" => "Bedömning av förslagen"
          },
          description: {
            "fi" => [
              "<p>",
              "Kaupungin palvelut kommentoivat ja arvioivat ehdotuksia suhteessa osallistuvan budjetoinnin reunaehtoihin. ",
              "Jokainen ehdotus luetaan ja merkitään joko sellaiseksi, että se täyttää annetut reunaehdot tai ei täytä niitä.",
              "</p>"
            ].join,
            "en" => [
              "<p>",
              "The City experts evaluate the proposals in terms of the framework for participatory budgeting. ",
              "Each proposal will be reviewed and marked according to whether it fits into the framework or not. ",
              "If a proposal does not fit into the framework, this will be explained in the online service.",
              "</p>"
            ].join,
            "sv" => [
              "<p>",
              "Stadens experter bedömer förslagen i relation till den deltagande budgeteringens specialvillkor. ",
              "Alla förslag ska läsas och varje ska markeras huruvida det uppfyller de givna villkoren eller inte. ",
              "Om ett förslag inte uppfyller specialvillkoren ges en motivering till detta i webbtjänsten.",
              "</p>"
            ].join
          },
          start_date: Date.new(2018, 12, 10),
          end_date: Date.new(2019, 1, 31),
          active: false
        )
        combined_process.steps.create!(
          position: 3,
          title: {
            "fi" => "Suunnittelu",
            "en" => "Planning",
            "sv" => "Planering"
          },
          description: {
            "fi" => [
              "<p>",
              "Ehdotuksista tehdään suunnitelmia yhdessä asukkaiden, kaupungin työntekijöiden, yhteisöjen ja yritysten kanssa. ",
              "Suunnitelmia tehdään OmaStadi palvelussa ja yhteisissä tapaamisissa. Suunnitelmaan yhdistetään useampia ehdotuksia. ",
              "Kaikki OmaStadi reunaehdot täyttävät ehdotukset otetaan mukaan suunnitelmiin. ",
              "Tavoitteena on tehdä tasalaatuisia suunnitelmia ja tukea yhdenvertaisuuden toteutumista. ",
              "Kaikki suunnitelmat näkyvät OmaStadi.hel.fi palvelussa, jossa niitä voi kommentoida. ",
              "Suunnitelmaan voidaan kerätä esimerkiksi useita samankaltaisia ehdotuksia ja yhdistää samaa aihepiiriä tai aluetta koskevia ehdotuksia. ",
              "Myös keskenään erilaiset ehdotukset voivat yhdessä muodostaa suunnitelman. OmaStadi -verkko palvelussa näkyy, mitkä ehdotukset kuhunkin suunnitelmaan on liitetty.",
              "</p>"
            ].join,
            "en" => [
              "<p>",
              "Proposals are developed into plans in cooperation between the city’s residents, employees, communities and companies. ",
              "Plans can be developed in the OmaStadi service and in meetings. Plans are made by combining different proposals. ",
              "All the proposals that fit into the framework of OmaStadi will be included in the plans. The purpose of the process is to make uniform plans and support equality. ",
              "All plans can be viewed and commented on in the OmaStadi.hel.fi service. ",
              "For instance, plans can include several similar proposals or combine proposals that concern the same topic or region. ",
              "Differing proposals can also be combined into a plan. You can browse the OmaStadi online service to see which proposals are included in a plan.",
              "</p>"
            ].join,
            "sv" => [
              "<p>",
              "Förslagen vidareutvecklas till planer i samarbete mellan invånarna, stadens medarbetare, föreningar och företag. ",
              "Planerna görs i OmaStadi-tjänsten och under de gemensamma träffarna. Flera förslag kombineras i planen. ",
              "Alla förslag som uppfyller ramvillkoren för OmaStadi-förslag inkluderas i planerna. Målet är att få fram planer av jämn kvalitet och stödja jämlikheten. ",
              "Alla planer visas på OmaStadi.hel.fi, där de också kan kommenteras. ",
              "Fler liknande förslag kan kombineras i en plan, och till exempel kan förslag som berör samma frågor eller samma område slås samman. ",
              "Också förslag som är sinsemellan olika kan tillsammans bilda en plan. I webbtjänsten OmaStadi visas vilka förslag som lagts till vilken plan.",
              "</p>"
            ].join
          },
          start_date: Date.new(2019, 2, 11),
          end_date: Date.new(2019, 4, 6),
          active: false
        )
        combined_process.steps.create!(
          position: 4,
          title: {
            "fi" => "Kustannusarviointi",
            "en" => "Cost estimates",
            "sv" => "Kostnadsuppskattning"
          },
          description: {
            "fi" => [
              "<p>",
              "Kaupungin toimialat tekevät suunnitelmille kustannuslaskelman, jossa huomioidaan kaikki suunnitelman toteuttamisesta aiheutuvat kulut. ",
              "Kustannuslaskelmassa huomioidaan esimerkiksi suunnittelukulut, jotka liittyvät kaikkiin rakennuskohteisiin. ",
              "Kustannuslaskelmien tekeminen on oma tärkeä OmaStadi vaiheensa, johon varataan aikaa kaksi kuukautta.",
              "</p>"
            ],
            "en" => [
              "<p>",
              "The City divisions will create cost estimates for the plans, where all the costs arising from the execution of the plan are considered. ",
              "The cost estimates include, for example, the expenses of the design of all construction sites. ",
              "The creation of cost estimates is an essential independent step of the OmaStadi process, and it takes approximately two months.",
              "</p>"
            ],
            "sv" => [
              "<p>",
              "Stadens sektorer gör upp kostnadsberäkningar för planerna, där alla kostnader som uppstår för genomförandet av dem beaktas. ",
              "I en kostnadsberäkning beaktas bland annat sådana planeringsutgifter som uppstår för alla byggobjekt. ",
              "Kostnadsberäkningen är ett viktigt skede i OmaStadi-budgeteringen och två månader reserveras för ändamålet.",
              "</p>"
            ]
          },
          start_date: Date.new(2019, 4, 7),
          end_date: Date.new(2019, 6, 15),
          active: false
        )
        combined_process.steps.create!(
          position: 5,
          title: {
            "fi" => "Äänestäminen",
            "en" => "Voting",
            "sv" => "Omröstning"
          },
          description: {
            "fi" => [
              "<p>",
              "Kaikki äänestysvuonna 12-vuotta täyttäneet helsinkiläiset ja sitä vanhemmat voivat äänestää osallistuvassa budjetoinnissa. ",
              "Voit äänestää yhden suurpiirin suunnitelmia ja sen lisäksi koko kaupunkia koskevia suunnitelmia. Äänestäminen tapahtuu omastadi.hel.fi palvelussa. ",
              "Äänestämään pääsee kirjautumalla omastadi.hel.fi palveluun pankkitunnuksilla tai mobiilivarmenteella. ",
              "Helsingin kaupungin kouluissa ja oppilaitoksissa nuoret voivat äänestää edu.hel.fi- tunnuksilla. ",
              "Äänestää voi myös kirjastoissa esittämällä kuvallisen henkilötodistuksen. Alle 18-vuotiaat voivat äänestää kirjastoissa esittämällä kela-kortin.",
              "</p>",
              "<p>",
              "Äänestyksessä jaetaan alueen määräraha usealle eri suunnitelmalle. Äänestyskoriin voi valita useita eri suunnitelmia, kunnes alueen rahasumma on käytetty. ",
              "Halutessaan voi äänestää myös vain yhtä suunnitelmaa.  Samalla tavalla voi äänestää myös koko kaupunkia koskevia suunnitelmia.",
              "</p>"
            ].join,
            "en" => [
              "<p>",
              "All residents of Helsinki aged 12 or over are eligible to vote in the participatory budgeting process. ",
              "You can vote both for plans for a major district and plans for the entire city. Voting takes place in the omastadi.hel.fi service. ",
              "You can cast your vote by signing into the omastadi.hel.fi service using your online banking credentials or mobile authentication. ",
              "Young people can vote with their edu.hel.fi login credentials in the City’s schools and educational institutions. ",
              "You can also vote in libraries by presenting a photo identity card. Young people under 18 can vote in libraries by presenting their Kela card.",
              "</p>",
              "<p>",
              "The districts’ appropriations are divided between several plans based on the vote. ",
              "You can include as many plans in your vote as the district’s appropriation allows for. It is also possible to vote for a single plan. ",
              "Plans that concern the entire city can also be combined in a similar manner.",
              "</p>"
            ].join,
            "sv" => [
              "<p>",
              "Alla Helsingforsbor som fyller 12 år eller mer under valåret får rösta i den deltagande budgeteringen. ",
              "Du får rösta på planerna i ett stordistrikt och på planer som gäller hela staden. Omröstningen sker i OmaStadi.hel.fi. ",
              "Man kommer åt att rösta i OmaStadi.hel.fi genom att logga in med sina bankkoder eller mobilcertifikat. ",
              "I Helsingfors stads skolor och läroinrättningar kan ungdomar rösta med sina edu.hel.fi-inloggningsuppgifter. ",
              "Man får också rösta i biblioteken genom att visa upp en bildförsedd identitetshandling. ",
              "Personer under 18 år kan rösta i biblioteken genom att visa upp sitt FPA-kort.",
              "</p>",
              "<p>",
              "I omröstningen fördelas områdets anslag på flera olika planer. Man kan lägga flera planer i röstningskorgen, så att hela områdets budgetmedel används upp. ",
              "Om man vill kan man också välja att bara rösta på en plan. På samma sätt kan man också rösta på planer som gäller hela staden.",
              "</p>"
            ].join
          },
          start_date: Date.new(2019, 10, 1),
          end_date: Date.new(2019, 10, 31),
          active: false
        )
        combined_process.steps.create!(
          position: 6,
          title: {
            "fi" => "Toteutus",
            "en" => "Execution",
            "sv" => "Genomförande"
          },
          description: {
            "fi" => [
              "<p>",
              "Pormestari vahvistaa äänestustuloksen ja valtuuttaa kaupungin palvelut toteuttamaan äänestyksessä voittaneet OmaStadi suunnitelmat. ",
              "Kaikki äänestyksessä valituiksi tulleet OmaStadi- suunnitelmat toteutetaan. Suunnitelmia lähdetään toteuttamaan nopeasti. ",
              "Kaupunki valitsee ja kilpailuttaa toimijat OmaStadi- suunnitelmien toteuttamiseksi omien säädöstensä mukaisesti. ",
              "Kaupunkilaisia kutsutaan mukaan tekemään ja toteuttamaan suunnitelmia sekä tietenkin juhlimaan yhteisien unelmien toteutumista.",
              "</p>"
            ],
            "en" => [
              "<p>",
              "The Mayor of the City will confirm the result of the vote and authorises the City services to execute the winning plans of the OmaStadi vote. ",
              "The execution of all OmaStadi plans selected in the vote will begin without delay. ",
              "The City will put up the OmaStadi plans up for tender and select the operators in accordance with its own regulations. ",
              "Residents of the city are invited to make plans and execute them, and of course, to celebrate the realisation of collective dreams.",
              "</p>"
            ],
            "sv" => [
              "<p>",
              "Borgmästaren stadfäster valresultatet och befullmäktigar stadens tjänster att genomföra de OmaStadi-planer som vunnit i valet. ",
              "Alla OmaStadi-planer som väljs ut i valet genomförs. Planerna börjar genomföras i rask takt. ",
              "Staden väljer och upphandlar entreprenörer för genomförandet i enlighet med det egna regelverket. ",
              "Stadsborna bjuds in för att göra och utföra planerna, och självklart för att fira att de gemensamma drömmarna blir verklighet.",
              "</p>"
            ]
          },
          start_date: Date.new(2019, 11, 1),
          end_date: Date.new(2020, 9, 13),
          active: true
        )

        # Create the categories
        combined_process.categories.create!(
          name: {
            "fi" => "Ekologisuus",
            "en" => "Ecofriendliness",
            "sv" => "Ekologi"
          },
          description: {
            "fi" => "Ekologisuus",
            "en" => "Ecofriendliness",
            "sv" => "Ekologi"
          },
          color: "#51bf9d"
        )
        combined_process.categories.create!(
          name: {
            "fi" => "Yhteisöllisyys",
            "en" => "Community",
            "sv" => "Gemenskap"
          },
          description: {
            "fi" => "Yhteisöllisyys",
            "en" => "Community",
            "sv" => "Gemenskap"
          },
          color: "#ffd400"
        )
        combined_process.categories.create!(
          name: {
            "fi" => "Terveys ja hyvinvointi",
            "en" => "Health and wellbeing",
            "sv" => "Hälsa och välmående"
          },
          description: {
            "fi" => "Terveys ja hyvinvointi",
            "en" => "Health and wellbeing",
            "sv" => "Hälsa och välmående"
          },
          color: "#f37021"
        )
        combined_process.categories.create!(
          name: {
            "fi" => "Kulttuuri",
            "en" => "Culture",
            "sv" => "Kultur"
          },
          description: {
            "fi" => "Kulttuuri",
            "en" => "Culture",
            "sv" => "Kultur"
          },
          color: "#f1a2c6"
        )
        combined_process.categories.create!(
          name: {
            "fi" => "Rakennettu ympäristö",
            "en" => "Built environment",
            "sv" => "Byggd miljö"
          },
          description: {
            "fi" => "Rakennettu ympäristö",
            "en" => "Built environment",
            "sv" => "Byggd miljö"
          },
          color: "#0072bc"
        )
        combined_process.categories.create!(
          name: {
            "fi" => "Oppiminen ja osaaminen",
            "en" => "Learning and skills",
            "sv" => "Inlärning och kunskap"
          },
          description: {
            "fi" => "Oppiminen ja osaaminen",
            "en" => "Learning and skills",
            "sv" => "Inlärning och kunskap"
          },
          color: "#a0c9ec"
        )
        combined_process.categories.create!(
          name: {
            "fi" => "Puistot ja luonto",
            "en" => "Parks and nature",
            "sv" => "Parker och natur"
          },
          description: {
            "fi" => "Puistot ja luonto",
            "en" => "Parks and nature",
            "sv" => "Parker och natur"
          },
          color: "#c69c4f"
        )
        combined_process.categories.create!(
          name: {
            "fi" => "Liikunta ja ulkoilu",
            "en" => "Sport and outdoors",
            "sv" => "Idrott och utomhusaktiviteter"
          },
          description: {
            "fi" => "Liikunta ja ulkoilu",
            "en" => "Sport and outdoors",
            "sv" => "Idrott och utomhusaktiviteter"
          },
          color: "#b2b5b7"
        )

        combined_process
      end

      def create_meetings_component
        meetings_component = combined_process.components.find_by(manifest_name: "meetings")
        return meetings_component if meetings_component

        manifest = Decidim.find_component_manifest("meetings")
        Decidim::Component.create!(
          manifest_name: "meetings",
          name: {
            "fi" => "Tapahtumat",
            "en" => "Meetings",
            "sv" => "Möten"
          },
          participatory_space: combined_process,
          weight: 60,
          settings: new_component_settings(
            manifest,
            :global,
            "comments_enabled" => true,
            "resources_permissions_enabled" => true,
            "enable_pads_creation" => false
          ),
          step_settings: {
            combined_process.steps[0].id.to_s => new_component_settings(
              manifest,
              :step,
              "comments_blocked" => false
            ),
            combined_process.steps[1].id.to_s => new_component_settings(
              manifest,
              :step,
              "comments_blocked" => false
            ),
            combined_process.steps[2].id.to_s => new_component_settings(
              manifest,
              :step,
              "comments_blocked" => false
            ),
            combined_process.steps[3].id.to_s => new_component_settings(
              manifest,
              :step,
              "comments_blocked" => false
            ),
            combined_process.steps[4].id.to_s => new_component_settings(
              manifest,
              :step,
              "comments_blocked" => false
            ),
            combined_process.steps[5].id.to_s => new_component_settings(
              manifest,
              :step,
              "comments_blocked" => false
            ),
            combined_process.steps[6].id.to_s => new_component_settings(
              manifest,
              :step,
              "comments_blocked" => false
            )
          },
          published_at: Time.now
        )
      end

      def create_proposals_component
        proposals_component = combined_process.components.find_by(manifest_name: "proposals")
        return proposals_component if proposals_component

        manifest = Decidim.find_component_manifest("proposals")
        Decidim::Component.create!(
          manifest_name: "proposals",
          name: {
            "fi" => "Ehdotukset 2018",
            "en" => "Proposals 2018",
            "sv" => "Förslagen 2018"
          },
          participatory_space: combined_process,
          weight: 40,
          settings: new_component_settings(
            manifest,
            :global,
            "vote_limit" => 0,
            "minimum_votes_per_user" => 0,
            "proposal_limit" => 20,
            "proposal_length" => 1000,
            "proposal_edit_before_minutes" => 60,
            "threshold_per_proposal" => 0,
            "can_accumulate_supports_beyond_threshold" => false,
            "proposal_answering_enabled" => true,
            "official_proposals_enabled" => false,
            "comments_enabled" => true,
            "geocoding_enabled" => true,
            "attachments_allowed" => true,
            "resources_permissions_enabled" => true,
            "collaborative_drafts_enabled" => false,
            "participatory_texts_enabled" => false,
            "amendments_enabled" => false,
            "new_proposal_help_text" => {
              "fi" => [
                '<p>Huomaathan ehdottaessasi seuraavat (ks. <a href="https://omastadi.hel.fi/assemblies/ohjeet/f/50/" target="_blank">ohjeet</a>):</p>',
                "<ul>",
                "<li>ehdotuksessa tulee esittää konkreettista asiaa, johon rahaa halutaan käyttää</li>",
                "<li>ehdotettavan asian tulee olla kaupungin toimivallassa&nbsp;(esimerkiksi ei poliisi, HSL tai HUS)</li>",
                "<li> ehdotuksessa ei voi hakea rahaa suoraan järjestölle tai muulle yhteisölle</li>",
                "</ul>",
                "<p><br></p>"
              ].join,
              "en" => "",
              "sv" => ""
            }
          ),
          step_settings: {
            combined_process.steps[0].id.to_s => new_component_settings(
              manifest,
              :step,
              "endorsements_enabled" => false,
              "endorsements_blocked" => false,
              "votes_enabled" => false,
              "votes_blocked" => false,
              "votes_hidden" => false,
              "comments_blocked" => false,
              "creation_enabled" => false,
              "proposal_answering_enabled" => false
            ),
            combined_process.steps[1].id.to_s => new_component_settings(
              manifest,
              :step,
              "endorsements_enabled" => true,
              "endorsements_blocked" => false,
              "votes_enabled" => false,
              "votes_blocked" => false,
              "votes_hidden" => false,
              "comments_blocked" => false,
              "creation_enabled" => true,
              "proposal_answering_enabled" => true
            ),
            combined_process.steps[2].id.to_s => new_component_settings(
              manifest,
              :step,
              "endorsements_enabled" => true,
              "endorsements_blocked" => false,
              "votes_enabled" => false,
              "votes_blocked" => false,
              "votes_hidden" => false,
              "comments_blocked" => false,
              "creation_enabled" => false,
              "proposal_answering_enabled" => true
            ),
            combined_process.steps[3].id.to_s => new_component_settings(
              manifest,
              :step,
              "endorsements_enabled" => true,
              "endorsements_blocked" => true,
              "votes_enabled" => false,
              "votes_blocked" => false,
              "votes_hidden" => false,
              "comments_blocked" => false,
              "creation_enabled" => false,
              "proposal_answering_enabled" => true
            ),
            combined_process.steps[4].id.to_s => new_component_settings(
              manifest,
              :step,
              "endorsements_enabled" => false,
              "endorsements_blocked" => false,
              "votes_enabled" => false,
              "votes_blocked" => false,
              "votes_hidden" => false,
              "comments_blocked" => false,
              "creation_enabled" => false,
              "proposal_answering_enabled" => true
            ),
            combined_process.steps[5].id.to_s => new_component_settings(
              manifest,
              :step,
              "endorsements_enabled" => false,
              "endorsements_blocked" => false,
              "votes_enabled" => false,
              "votes_blocked" => false,
              "votes_hidden" => false,
              "comments_blocked" => false,
              "creation_enabled" => false,
              "proposal_answering_enabled" => true
            ),
            combined_process.steps[6].id.to_s => new_component_settings(
              manifest,
              :step,
              "endorsements_enabled" => false,
              "endorsements_blocked" => false,
              "votes_enabled" => false,
              "votes_blocked" => false,
              "votes_hidden" => true,
              "comments_blocked" => false,
              "creation_enabled" => false,
              "proposal_answering_enabled" => true
            )
          },
          published_at: Time.now
        )
      end

      def create_plans_component
        plans_component = combined_process.components.find_by(manifest_name: "plans")
        return plans_component if plans_component

        manifest = Decidim.find_component_manifest("plans")
        plans_component = Decidim::Component.create!(
          manifest_name: "plans",
          name: {
            "fi" => "Suunnitelmat",
            "en" => "Plans",
            "sv" => "Planer"
          },
          participatory_space: combined_process,
          weight: 30,
          settings: new_component_settings(
            manifest,
            :global,
            "plan_title_length" => 100,
            "plan_answering_enabled" => true,
            "comments_enabled" => true,
            "scopes_enabled" => true,
            "categories_enabled" => false,
            "proposal_linking_enabled" => true,
            "attachments_allowed" => true,
            "closing_allowed" => false,
            "multilingual_answers" => false
          ),
          step_settings: {
            combined_process.steps[0].id.to_s => new_component_settings(
              manifest,
              :step,
              "comments_blocked" => false,
              "creation_enabled" => false,
              "plan_answering_enabled" => false
            ),
            combined_process.steps[1].id.to_s => new_component_settings(
              manifest,
              :step,
              "comments_blocked" => false,
              "creation_enabled" => false,
              "plan_answering_enabled" => false
            ),
            combined_process.steps[2].id.to_s => new_component_settings(
              manifest,
              :step,
              "comments_blocked" => false,
              "creation_enabled" => false,
              "plan_answering_enabled" => false
            ),
            combined_process.steps[3].id.to_s => new_component_settings(
              manifest,
              :step,
              "comments_blocked" => false,
              "creation_enabled" => true,
              "plan_answering_enabled" => false
            ),
            combined_process.steps[4].id.to_s => new_component_settings(
              manifest,
              :step,
              "comments_blocked" => false,
              "creation_enabled" => false,
              "plan_answering_enabled" => true
            ),
            combined_process.steps[5].id.to_s => new_component_settings(
              manifest,
              :step,
              "comments_blocked" => false,
              "creation_enabled" => false,
              "plan_answering_enabled" => false
            ),
            combined_process.steps[6].id.to_s => new_component_settings(
              manifest,
              :step,
              "comments_blocked" => false,
              "creation_enabled" => false,
              "plan_answering_enabled" => false
            )
          },
          published_at: Time.now
        )

        # Create sections
        Decidim::Plans::Section.create!(
          position: 0,
          component: plans_component,
          body: {
            "fi" => "Suunnitelman tiivistelmä",
            "en" => "Summary",
            "sv" => "Kort beskrivning "
          },
          help: {
            "fi" => "Lyhyt kuvaus suunnitelman tavoitteesta ja siitä mitä tehdään.",
            "en" => "",
            "sv" => ""
          },
          mandatory: true,
          answer_length: 500,
          section_type: "field_text_multiline"
        )
        Decidim::Plans::Section.create!(
          position: 1,
          component: plans_component,
          body: {
            "fi" => "Sijainti",
            "en" => "Location on the map",
            "sv" => "Lokalisering pä kartan"
          },
          help: {
            "fi" => "Tarkka osoite, kaupunginosa tai muu sijainti, jonka karttapalvelu tunnistaa (jos olemassa).",
            "en" => "",
            "sv" => ""
          },
          mandatory: false,
          answer_length: 50,
          section_type: "field_text"
        )
        Decidim::Plans::Section.create!(
          position: 2,
          component: plans_component,
          body: {
            "fi" => "Kohderyhmä",
            "en" => "Target group",
            "sv" => "Målgrupp"
          },
          help: {
            "fi" => "Kenen elämään ehdotus vaikuttaa ensisijaisesti?",
            "en" => "",
            "sv" => ""
          },
          mandatory: true,
          answer_length: 500,
          section_type: "field_text_multiline"
        )
        Decidim::Plans::Section.create!(
          position: 3,
          component: plans_component,
          body: {
            "fi" => "Tavoitteet",
            "en" => "Objectives",
            "sv" => "Målbeskrivning"
          },
          help: {
            "fi" => "Mitä halutaan saada aikaan? Millaisia positiivisia vaikutuksia suunnitelmalla on? Mihin toiveeseen, tarpeeseen, puutteeseen tai ongelmaan ehdotus vastaa?",
            "en" => "",
            "sv" => ""
          },
          mandatory: false,
          answer_length: 1000,
          section_type: "field_text_multiline"
        )
        Decidim::Plans::Section.create!(
          position: 4,
          component: plans_component,
          body: {
            "fi" => "Toimenpiteet",
            "en" => "Key actions on which funds will be spend",
            "sv" => "Åtgärder som det behövs pengar för"
          },
          help: {
            "fi" => "Mitä tavoitteiden saavuttamiseksi tehdään? Mihin asioihin OmaStadi rahaa halutaan käyttää?",
            "en" => "",
            "sv" => ""
          },
          mandatory: true,
          answer_length: 1000,
          section_type: "field_text_multiline"
        )
        Decidim::Plans::Section.create!(
          position: 5,
          component: plans_component,
          body: {
            "fi" => "Toteutukseen osallistuvat yhteisöt ja ihmiset",
            "en" => "The people and communities participating in the execution",
            "sv" => "Personer och organisationer som  deltar i genomförandet"
          },
          help: {
            "fi" => [
              "Kuka vastaa mahdollisesta ehdotuksen mukaisen toiminnan järjestämisestä?",
              "Kenen vastuulla on kohteen ylläpito?",
              "Ketkä osallistuvat suunnitelman toteutukseen?",
              "Miten suunnitteluun ja toteutukseen halutaan osallistua?"
            ].join(" \n"),
            "en" => "",
            "sv" => ""
          },
          mandatory: true,
          answer_length: 500,
          section_type: "field_text_multiline"
        )

        plans_component
      end

      def create_budgets_overview_component
        budgets_overview_component = combined_process.components.find_by(manifest_name: "pages")
        return budgets_overview_component if budgets_overview_component && budgets_overview_component.name["fi"] == "Äänestys"

        manifest = Decidim.find_component_manifest("pages")
        Decidim::Component.create!(
          manifest_name: "pages",
          name: {
            "fi" => "Äänestys",
            "en" => "Budgets",
            "sv" => "Budgetar"
          },
          participatory_space: combined_process,
          weight: 20,
          settings: new_component_settings(
            manifest,
            :global,
            {}
          ),
          step_settings: {
            combined_process.steps[0].id.to_s => new_component_settings(
              manifest,
              :step,
              {}
            ),
            combined_process.steps[1].id.to_s => new_component_settings(
              manifest,
              :step,
              {}
            ),
            combined_process.steps[2].id.to_s => new_component_settings(
              manifest,
              :step,
              {}
            ),
            combined_process.steps[3].id.to_s => new_component_settings(
              manifest,
              :step,
              {}
            ),
            combined_process.steps[4].id.to_s => new_component_settings(
              manifest,
              :step,
              {}
            ),
            combined_process.steps[5].id.to_s => new_component_settings(
              manifest,
              :step,
              {}
            ),
            combined_process.steps[6].id.to_s => new_component_settings(
              manifest,
              :step,
              {}
            )
          },
          published_at: Time.now
        )
      end

      def update_budgets_step_settings
        manifest = Decidim.find_component_manifest("budgets")
        combined_process.components.where(manifest_name: "budgets").each do |component|
          component.update!(
            step_settings: {
              combined_process.steps[0].id.to_s => new_component_settings(
                manifest,
                :step,
                "comments_blocked" => false,
                "votes_enabled" => false,
                "show_votes" => false
              ),
              combined_process.steps[1].id.to_s => new_component_settings(
                manifest,
                :step,
                "comments_blocked" => false,
                "votes_enabled" => false,
                "show_votes" => false
              ),
              combined_process.steps[2].id.to_s => new_component_settings(
                manifest,
                :step,
                "comments_blocked" => false,
                "votes_enabled" => false,
                "show_votes" => false
              ),
              combined_process.steps[3].id.to_s => new_component_settings(
                manifest,
                :step,
                "comments_blocked" => false,
                "votes_enabled" => false,
                "show_votes" => false
              ),
              combined_process.steps[4].id.to_s => new_component_settings(
                manifest,
                :step,
                "comments_blocked" => false,
                "votes_enabled" => false,
                "show_votes" => false
              ),
              combined_process.steps[5].id.to_s => new_component_settings(
                manifest,
                :step,
                "comments_blocked" => false,
                "votes_enabled" => true,
                "show_votes" => true
              ),
              combined_process.steps[6].id.to_s => new_component_settings(
                manifest,
                :step,
                "comments_blocked" => false,
                "votes_enabled" => false,
                "show_votes" => true
              )
            }
          )
        end
      end

      def create_accountability_component
        accountability_component = combined_process.components.find_by(manifest_name: "accountability")
        return accountability_component if accountability_component

        manifest = Decidim.find_component_manifest("accountability")
        Decidim::Component.create!(
          manifest_name: "accountability",
          name: {
            "fi" => "Seuranta",
            "en" => "Accountability",
            "sv" => "Ansvarsskyldighet"
          },
          participatory_space: combined_process,
          weight: 10,
          settings: new_component_settings(
            manifest,
            :global,
            "comments_enabled" => true,
            "display_progress_enabled" => true
          ),
          step_settings: {
            combined_process.steps[0].id.to_s => new_component_settings(
              manifest,
              :step,
              "comments_blocked" => false
            ),
            combined_process.steps[1].id.to_s => new_component_settings(
              manifest,
              :step,
              "comments_blocked" => false
            ),
            combined_process.steps[2].id.to_s => new_component_settings(
              manifest,
              :step,
              "comments_blocked" => false
            ),
            combined_process.steps[3].id.to_s => new_component_settings(
              manifest,
              :step,
              "comments_blocked" => false
            ),
            combined_process.steps[4].id.to_s => new_component_settings(
              manifest,
              :step,
              "comments_blocked" => false
            ),
            combined_process.steps[5].id.to_s => new_component_settings(
              manifest,
              :step,
              "comments_blocked" => false
            ),
            combined_process.steps[6].id.to_s => new_component_settings(
              manifest,
              :step,
              "comments_blocked" => false
            )
          },
          published_at: Time.now
        )
      end
    end
  end
end
