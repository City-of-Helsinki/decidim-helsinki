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
    class SingleProcessRuuti < SingleProcessBase
      PROCESS_SCOPE_MAP = {
        "etelainen" => "RUUTIETELÄINEN",
        "haaga" => "RUUTIHAAGA",
        "hesua" => "RUUTIHESUA",
        "herttoniemi" => "RUUTIHERTTONIEMI",
        "itakeskus" => "RUUTIITÄKESKUS",
        "kannelmaki" => "RUUTIKANNELMÄKI",
        "koillinen" => "RUUTIKOILLINEN",
        "kontula" => "RUUTIKONTULA",
        "malmi" => "RUUTIMALMI",
        "maunula" => "RUUTIMAUNULA",
        "munkkiniemi" => "RUUTIMUNKKINIEMI",
        "pasila" => "RUUTIPASILA",
        "viikki" => "RUUTIVIIKKI",
        "vuosaari" => "RUUTIVUOSAARI",
        "ymparistotoiminta" => "RUUTIYMPÄRISTÖTOIMINTA"
      }.freeze

      def migrate
        # Create the new components
        meetings_component = create_meetings_component
        plans_component = create_plans_component
        accountability_component = create_accountability_component

        # Initialize plan mover
        plan_mover = Decidim::Plans::PlanMover.new(plans_component)
        plan_mover.allow_section_mismatch!

        index = 0
        PROCESS_SCOPE_MAP.each do |process_slug, scope_code|
          process = Decidim::ParticipatoryProcess.find_by(slug: process_slug)
          scope = Decidim::Scope.find_by(code: scope_code)

          raise "No process found: #{process_slug}" unless process
          raise "No scope found: #{scope_code}" unless scope

          process_followers_to_scope_interests(process, scope)

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

          # Move plans to the new component
          plan_maps = {}
          if process_slug == "haaga"
            # The content sections have been incorrectly set for the Haaga area.
            # The "Miten nuoret osallistuvat toteutukseen?" is completely
            # missing from that area which is why we need to map the sections
            # manually.
            from_plans_component = process.components.find_by(manifest_name: "plans")

            from_sections = Decidim::Plans::Section.where(component: from_plans_component).order(:position)
            to_sections = Decidim::Plans::Section.where(component: plans_component).order(:position)

            ind = -1
            plan_maps[:sections] = to_sections.map do |to_section|
              next if to_section.body["fi"] == "Miten nuoret osallistuvat toteutukseen?"

              ind += 1
              [from_sections[ind].id, to_section.id]
            end.compact.to_h
          end
          move_plans_to_other_component(process, plan_mover, scope, plan_maps)

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
          remap_accountability_result_details(process, accountability_component)
          remap_accountability_result_statuses(process, accountability_component)

          process.destroy!
          index += 1
        end

        create_budgets_overview_page(create_budgets_overview_component)
        update_budgets_step_settings

        combined_process.publish!

        # Redirect the old process group URL to the combined process and
        # remove the process group.
        group = Decidim::ParticipatoryProcessGroup.find_by(
          "name->>'fi' =?", "Nuorten Ruutibudjetti"
        )
        set_redirection(
          "/processes_groups/#{group.id}",
          "/processes/#{combined_process.slug}"
        )
        group.destroy!

        # Redirect the accountability combination page
        set_redirection(
          "/results/nuorten-ruutibudjetti",
          "/processes/#{combined_process.slug}/f/#{accountability_component.id}/"
        )
      end

      private

      def create_combined_process
        combined_process = Decidim::ParticipatoryProcess.find_by(slug: "ruuti-2019")
        return combined_process if combined_process

        base_path = File.expand_path(Rails.root.join("app/assets/images/helsinki/ruuti-2019"))

        hero_image = Pathname.new("#{base_path}/hero.jpg").open
        banner_image = Pathname.new("#{base_path}/banner.png").open
        main_scope = Decidim::Scope.find_by(code: "RUUTIALUE")

        combined_process = Decidim::ParticipatoryProcess.create!(
          organization: Decidim::Organization.first,
          title: {
            "fi" => "RuutiBudjetti 2019-2020",
            "en" => "RuutiBudjetti 2019-2020",
            "sv" => "RuutiBudjetti 2019-2020"
          },
          subtitle: {
            "fi" => [
              "RuutiBudjetti on yläkouluikäisille suunnattu osallistuvan budjetoinnin malli, jossa nuoret pääsevät vaikuttamaan vapaa-aika- ja harrastusmahdollisuuksiin, ",
              "alueensa nuorisotyöyksikön resurssien suuntaamiseen sekä muihin nuoria koskeviin asioihin. RuutiBudjetista vastaa Helsingin nuorisopalvelut."
            ].join,
            "en" => "",
            "sv" => ""
          },
          slug: "ruuti-2019",
          description: {
            "fi" => [
              "<p><strong>Äänestyksen aikataulu sekä ohjeet tunnistautumiseen päivitetään ennen äänestyksen alkamista.</strong></p>",
              "<p></p>",
              "<h3>Mikä on RuutiBudjetti?</h3>",
              "<p>",
              "RuutiBudjetissa päätetään yhdessä vuosittain siitä, miten Helsingin eri alueiden varoja kohdennetaan nuorten vapaa-ajan, harrastusmahdollisuuksien, palvelujen ",
              "ja koko kaupungin kehittämisessä. RuutiBudjetti on suunnattu 6.-9. -luokkalaisille, ja sitä toteutetaan Helsingin kunkin alueen nuorisotyöyksikön ja seudun ",
              "koulujen yhteistyönä. Osallistujia on ollut vuosittain noin 11 000.",
              "</p>",
              "<p></p>",
              "<h3>Miten ja mihin RuutiBudjetissa vaikutetaan?</h3>",
              "<p>",
              "RuutiBudjetissa nuoret pääsevät vaikuttamaan kaupungin nuorisopalveluiden kunkin yksikön budjettiin. Lisäksi nuorisopalvelut jakaa vuosittain 150 000 euroa ",
              "isompien suunnitelmien kesken. RuutiBudjetti etenee vuosittain neljässä vaiheessa: tiedonkeruu, työpajat, äänestys ja neuvottelukunnat. ",
              '<a href="https://omastadi.hel.fi/pages/mitenruutibudjettietenee" target="_blank">Ohjeet-sivulta</a>',
              "</p>"
            ].join,
            "en" => "",
            "sv" => ""
          },
          short_description: {
            "fi" => [
              "<p>",
              "Syyskaudella 2020 äänestetään jälleen siitä mitä nuorten kehittämiä suunnitelmia Helsingissä toteutetaan ensi vuonna! Äänioikeutettuja ovat 6.-9. -luokkalaiset. ",
              "Kouluilla järjestetään äänestysaikana tilaisuuksia, joissa nuoriso-ohjaajat, opettajat ja oppilaskunnat auttavat nuoria tutustumaan suunnitelmiin ja äänestämään. ",
              "Äänestää voi myös itsenäisesti.",
              "</p>"
            ].join,
            "en" => "",
            "sv" => ""
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
          start_date: Date.new(2019, 4, 1),
          end_date: Date.new(2019, 12, 3)
        )

        # Create the steps
        combined_process.steps.create!(
          position: 0,
          title: {
            "fi" => "Tiedonkeruu",
            "en" => "Introduction",
            "sv" => "Introduktion"
          },
          description: {
            "fi" => [
              "<p>",
              "RuutiBudjetti starttaa huhti- ja toukokuussa tiedonkeruilla. ",
              "Kaikki nuorisopalveluiden yksiköt toteuttavat tiedonkeruuta alueen nuorille ja kouluille sopivalla tavalla. ",
              "Useimmiten tiedonkeruu toteutetaan RuBuFestinä, jossa kaupungin eri toimijat kartoittavat nuorten toiveita, huolia ja ideoita toiminnallisissa pisteissä tai ",
              "työpajoissa. Tiedonkeruuseen osallistutaan yeleensä luokka-asteittain alueen kouluista.",
              "</p>"
            ].join,
            "en" => "",
            "sv" => ""
          },
          start_date: Date.new(2019, 4, 1),
          end_date: Date.new(2019, 5, 31),
          active: false
        )
        combined_process.steps.create!(
          position: 1,
          title: {
            "fi" => "Työpajat",
            "en" => "",
            "sv" => ""
          },
          description: {
            "fi" => [
              "<p>",
              "Touko- ja syyskuun välillä järjestettävissä työpajoissa vapaaehtoiset nuoret käyvät nuoriso-ohjaajien avulla läpi oman alueensa tiedonkeruussa syntynyttä ",
              "materiaalia. Materiaali voidaan esimerkiksi teemoitella, ja tehdä siitä erilaisia nostoja. ",
              "Työpajan lopputuotoksena on erilaisia nuorten yhdessä tekemiä suunnitelmia, jotka voivat olla luonteeltaan joko suoria toimenpide-ehdotuksia, tai aloitteita. ",
              "Kaikille suunnitelmille pyritään tekemään suuntaa-antava kustannusarvio yhdessä nuorten kanssa.",
              "</p>"
            ].join,
            "en" => "",
            "sv" => ""
          },
          start_date: Date.new(2019, 4, 1),
          end_date: Date.new(2019, 9, 30),
          active: false
        )
        combined_process.steps.create!(
          position: 2,
          title: {
            "fi" => "Äänestys",
            "en" => "",
            "sv" => ""
          },
          description: {
            "fi" => [
              "<p>",
              "Työpajoissa tehdyt, kustannusarvioidut suunnitelmat viedään alueen kouluille äänestykseen. ",
              "Vuonna 2019 äänestys toteutetaan kaikilla alueilla ensimmäistä kertaa Omastadi-alustassa. Äänioikeutettuja ovat kaikki Helsingin 6.-9. luokilla opiskelevat. ",
              "Äänestys on Omastadi-alustassa auki 1.-31.10.2019. ",
              "Tuolla aikavälillä nuorisotyöyksiköt, opettajat ja oppilaskunta-aktiivit järjestävät kouluilla infoja ja äänestystempauksia.",
              "</p>"
            ].join,
            "en" => "",
            "sv" => ""
          },
          start_date: Date.new(2019, 10, 1),
          end_date: Date.new(2019, 10, 31),
          active: false
        )
        combined_process.steps.create!(
          position: 3,
          title: {
            "fi" => "Neuvottelukunnat",
            "en" => "",
            "sv" => ""
          },
          description: {
            "fi" => [
              "<p>",
              "Neuvottelukunta kootaan alueella äänestyksen jälkeen. ",
              "Neuvottelukunnan osallistujia ovat alueen vapaaehtoiset nuoret, alueen nuorisopalveluiden yksikön toiminnanjohtaja sekä alueella tehtyjen ",
              "RuutiBudjetti-suunnitelmien aihepiireihin liittyviä viranhaltijoita, asiantuntijoita ja päättäjiä. ",
              "Neuvottelukuntaan osallistuville kerrotaan mistä budjeteista ja resursseista ollaan päättämässä. ",
              "Neuvottelukunnassa käydään läpi ja vahvistetaan alueen RuutiBudjetti-äänestystulos, sekä tehdään päätös millä tavoin kutakin suunnitelmaa lähdetään edistämään.",
              "</p>"
            ].join,
            "en" => "",
            "sv" => ""
          },
          start_date: Date.new(2019, 11, 1),
          end_date: Date.new(2019, 11, 19),
          active: false
        )
        combined_process.steps.create!(
          position: 4,
          title: {
            "fi" => "Toteutus",
            "en" => "",
            "sv" => ""
          },
          description: {
            "fi" => "<p>Neuvottelukunnassa toteutettaviksi päätetyt suunnitelmat toteutetaan seuraavan budjettivuoden aikana, jollei erityisestä syystä toisin sovita.</p>",
            "en" => "",
            "sv" => ""
          },
          start_date: Date.new(2020, 1, 1),
          end_date: Date.new(2020, 12, 31),
          active: true
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
          weight: 20,
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
            )
          }
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
            "title_help" => {
              "fi" => "esim. Festari nuorille Kannelmäessä",
              "en" => "",
              "sv" => ""
            },
            "scopes_enabled" => true,
            "categories_enabled" => false,
            "proposal_linking_enabled" => false,
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
              "creation_enabled" => true,
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
              "creation_enabled" => false,
              "plan_answering_enabled" => false
            ),
            combined_process.steps[4].id.to_s => new_component_settings(
              manifest,
              :step,
              "comments_blocked" => false,
              "creation_enabled" => false,
              "plan_answering_enabled" => false
            )
          }
        )

        # Create sections
        Decidim::Plans::Section.create!(
          position: 0,
          component: plans_component,
          body: {
            "fi" => "Tiivistelmä",
            "en" => "",
            "sv" => " "
          },
          help: {
            "fi" => "Kerro muutamalla lauseella mistä suunnitelmassa on kyse.",
            "en" => "",
            "sv" => ""
          },
          mandatory: true,
          answer_length: 0,
          section_type: "field_text_multiline"
        )
        Decidim::Plans::Section.create!(
          position: 1,
          component: plans_component,
          body: {
            "fi" => "Sijainti",
            "en" => "",
            "sv" => ""
          },
          help: {
            "fi" => "Missä päin kaupunkia tapahtuu vai koko kaupunki?",
            "en" => "",
            "sv" => ""
          },
          mandatory: true,
          answer_length: 0,
          section_type: "field_text"
        )
        Decidim::Plans::Section.create!(
          position: 2,
          component: plans_component,
          body: {
            "fi" => "Tavoitteet",
            "en" => "",
            "sv" => ""
          },
          help: {
            "fi" => "Miksi tämä tehdään? Mikä on tavoitteena?",
            "en" => "",
            "sv" => ""
          },
          mandatory: true,
          answer_length: 0,
          section_type: "field_text_multiline"
        )
        Decidim::Plans::Section.create!(
          position: 3,
          component: plans_component,
          body: {
            "fi" => "Toimenpiteet",
            "en" => "",
            "sv" => ""
          },
          help: {
            "fi" => "Mitä konkreettisia toimenpiteitä tarvitaan?",
            "en" => "",
            "sv" => ""
          },
          mandatory: true,
          answer_length: 0,
          section_type: "field_text_multiline"
        )
        Decidim::Plans::Section.create!(
          position: 4,
          component: plans_component,
          body: {
            "fi" => "Kohderyhmä",
            "en" => "",
            "sv" => ""
          },
          help: {
            "fi" => "Keille tämä on suunnattu? Keitä tavoitellaan osallistumaan?",
            "en" => "",
            "sv" => ""
          },
          mandatory: true,
          answer_length: 0,
          section_type: "field_text_multiline"
        )
        Decidim::Plans::Section.create!(
          position: 5,
          component: plans_component,
          body: {
            "fi" => "Miten nuoret osallistuvat toteutukseen?",
            "en" => "",
            "sv" => ""
          },
          help: {
            "fi" => "Miten nuoret voivat osallistua suunnitteluun, toteutukseen jne?",
            "en" => "",
            "sv" => ""
          },
          mandatory: true,
          answer_length: 0,
          section_type: "field_text_multiline"
        )
        Decidim::Plans::Section.create!(
          position: 6,
          component: plans_component,
          body: {
            "fi" => "Mitä muita toimijoita tarvitaan mukaan?",
            "en" => "",
            "sv" => ""
          },
          help: {
            "fi" => "esim. Nuorisotyöyksikkö, koulu, joka muu kaupungin toimija, järjestö.",
            "en" => "",
            "sv" => ""
          },
          mandatory: true,
          answer_length: 0,
          section_type: "field_text_multiline"
        )
        Decidim::Plans::Section.create!(
          position: 7,
          component: plans_component,
          body: {
            "fi" => "Kustannusarvio",
            "en" => "",
            "sv" => ""
          },
          help: {
            "fi" => "Suuntaa-antava arvio. Jollei arviota osata tehdä yksikössä, jätetään tähän nolla, ja nupassa asiantuntijatiimi kehittää arvion.",
            "en" => "",
            "sv" => ""
          },
          mandatory: true,
          answer_length: 0,
          section_type: "field_text"
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
          weight: 10,
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
            )
          },
          published_at: Time.current
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
                "votes_enabled" => true,
                "show_votes" => false
              ),
              combined_process.steps[3].id.to_s => new_component_settings(
                manifest,
                :step,
                "comments_blocked" => false,
                "votes_enabled" => false,
                "show_votes" => true
              ),
              combined_process.steps[4].id.to_s => new_component_settings(
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
        component = Decidim::Component.create!(
          manifest_name: "accountability",
          name: {
            "fi" => "Edistyminen",
            "en" => "Accountability",
            "sv" => "Ansvarsskyldighet"
          },
          participatory_space: combined_process,
          weight: 40,
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
            )
          },
          published_at: Time.current
        )

        # Add the default details
        Decidim::AccountabilitySimple::ResultDetail.create!(
          title: {
            "fi" => "Hinta",
            "en" => "Price",
            "sv" => "Pris"
          },
          icon: "budget",
          position: 0,
          accountability_result_detailable: component
        )
        Decidim::AccountabilitySimple::ResultDetail.create!(
          title: {
            "fi" => "Sijainti",
            "en" => "Location",
            "sv" => "Plats"
          },
          icon: "map-marker",
          position: 1,
          accountability_result_detailable: component
        )
        Decidim::AccountabilitySimple::ResultDetail.create!(
          title: {
            "fi" => "Vuosi",
            "en" => "Year",
            "sv" => "År"
          },
          icon: "calendar",
          position: 2,
          accountability_result_detailable: component
        )
        Decidim::AccountabilitySimple::ResultDetail.create!(
          title: {
            "fi" => "Äänet",
            "en" => "Votes",
            "sv" => "Röster"
          },
          icon: "vote",
          position: 3,
          accountability_result_detailable: component
        )
        Decidim::AccountabilitySimple::ResultDetail.create!(
          title: {
            "fi" => "Yhteyshenkilö",
            "en" => "Contact",
            "sv" => "Kontakt"
          },
          icon: "person",
          position: 4,
          accountability_result_detailable: component
        )

        # Add the statuses
        Decidim::Accountability::Status.create!(
          component: component,
          key: "initiative",
          name: {
            "fi" => "Aloite",
            "en" => "Initiative",
            "sv" => "Initiativ"
          },
          description: {
            "fi" => "",
            "en" => "",
            "sv" => ""
          },
          progress: nil
        )
        Decidim::Accountability::Status.create!(
          component: component,
          key: "planning",
          name: {
            "fi" => "Suunnittelu aloitettu",
            "en" => "Planning started",
            "sv" => "Planeringen startade"
          },
          description: {
            "fi" => "",
            "en" => "",
            "sv" => ""
          },
          progress: 25
        )
        Decidim::Accountability::Status.create!(
          component: component,
          key: "preparation",
          name: {
            "fi" => "Esivalmistelut",
            "en" => "Preparation",
            "sv" => "Förberedelser"
          },
          description: {
            "fi" => "",
            "en" => "",
            "sv" => ""
          },
          progress: 50
        )
        Decidim::Accountability::Status.create!(
          component: component,
          key: "progress",
          name: {
            "fi" => "Käynnissä",
            "en" => "In progress",
            "sv" => "Pågar"
          },
          description: {
            "fi" => "",
            "en" => "",
            "sv" => ""
          },
          progress: 75
        )
        Decidim::Accountability::Status.create!(
          component: component,
          key: "completed",
          name: {
            "fi" => "Valmis",
            "en" => "Completed",
            "sv" => "Färdig"
          },
          description: {
            "fi" => "",
            "en" => "",
            "sv" => ""
          },
          progress: 100
        )

        component
      end
    end
  end
end
