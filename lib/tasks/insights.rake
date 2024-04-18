# frozen_string_literal: true

namespace :insights do
  # Import the area insights data from custom Excel files.
  # The first file contains the basic data fro each area and the second file
  # contains the additional categorized details and the plans for the area.
  desc "Import area insights."
  task :import, [:organization_id, :data_path] => [:environment] do |_t, args|
    organization = Decidim::Organization.find(args[:organization_id])
    section = Decidim::Insights::Section.find_by(organization: organization, slug: "areas")
    section ||= Decidim::Insights::Section.create(
      organization: organization,
      slug: "areas",
      name: {
        fi: "Tietoa alueista",
        sv: "Information om områdena",
        en: "Information on districts"
      }
    )

    data_path = args[:data_path]
    if data_path.blank? || !File.directory?(data_path)
      puts "The provided data path does not exist, please check the path."
      next
    end

    files = {
      areas: "#{data_path}/insights.xlsx",
      info: "#{data_path}/raw-data.xlsx",
      views: "#{data_path}/citizen-views.xlsx"
    }
    unless files.values.all? { |f| File.exist?(f) }
      puts "Import files were not found, please check that the data path contains all the files."
      next
    end

    require "rubyXL"
    require "rubyXL/convenience_methods"

    # Process the basic data and area democraphic data
    area_info = parse_area_info(files[:areas])
    area_path = File.dirname(files[:areas])
    data_mapping = {
      areas: {},
      categories: {},
      scopes: {}
    }
    area_info[:areas].each do |data|
      area = Decidim::Insights::Area.create!(
        section: section,
        slug: data["slug"],
        position: data["position"],
        name: {
          fi: data["name/fi"],
          sv: data["name/sv"],
          en: data["name/en"]
        },
        title: {
          fi: data["title/fi"],
          sv: data["title/sv"],
          en: data["title/en"]
        },
        summary: {
          fi: data["summary/fi"],
          sv: data["summary/sv"],
          en: data["summary/en"]
        },
        description: {
          fi: data["description/fi"],
          sv: data["description/sv"],
          en: data["description/en"]
        },
        show_banner: true,
        banner_text: {
          fi: "<p>Heräsikö ajatuksia, mitä kaupunki kaipaa? Siirry tekemään ehdotus!</p>",
          sv: "<p>Tänkte du på något som staden behöver? Lämna in ett förslag!</p>",
          en: "<p>Did you think of anything that the city needs? Make a proposal!</p>"
        },
        banner_cta_text: {
          fi: "Tee ehdotus",
          sv: "Lämna in ett förslag",
          en: "Make a proposal"
        },
        banner_cta_link: {
          fi: "#"
        }
      )
      image_path = nil
      image_path = "#{area_path}/#{data["image"]}" if data["image"].present?
      area.image.attach(io: File.open(image_path), filename: File.basename(image_path)) if image_path && File.exist?(image_path)

      data_mapping[:areas][data["slug"]] = area
    end
    area_info[:categories].each do |data|
      category = Decidim::Category.where(participatory_space: section).find_by("name->>'fi' = ?", data["name/fi"])
      category ||= Decidim::Category.create!(
        name: {
          fi: data["name/fi"],
          sv: data["name/sv"],
          en: data["name/en"]
        },
        participatory_space: section
      )
      data_mapping[:categories][data["key"]] = category
    end

    # Scopes should be pre-entered on the system with the defined keys.
    if (sector_top_scope = Decidim::Scope.find_by(organization: organization, code: "TOIMIALA"))
      sector_top_scope.children.each do |scope|
        data_mapping[:scopes][scope.code.split("-").last] = scope
      end
    end

    total_population = area_info[:population][:data]["total"]
    whole_city_label = { fi: "Koko kaupunki", sv: "Hel stad", en: "Whole city" }
    area_info[:population][:data].each do |key, data|
      next if key == "total"

      area = data_mapping[:areas][key]
      Decidim::Insights::AreaDetail.create!(
        area: area,
        position: 0,
        sticky: true,
        detail_type: "column_comparison",
        title: {
          fi: "Kuinka moni asuu täällä?",
          sv: "Hur många människor bor här?",
          en: "How many people live here?"
        },
        source: area_info[:population][:source],
        data: {
          # Visible labels in the views
          labels: [nil, whole_city_label],
          # Aria labels for screen readers
          value_labels: [area.title, whole_city_label],
          group_label: { fi: "Ikäluokka", sv: "Åldersgrupp", en: "Age group" },
          groups: data.keys.map do |grp|
            {
              group: grp,
              values: [data[grp].to_i, total_population[grp].to_i]
            }
          end
        }
      )
    end

    area_info[:activity][:data].each do |key, data|
      Decidim::Insights::AreaDetail.create!(
        area: data_mapping[:areas][key],
        position: 1,
        sticky: true,
        detail_type: "donut",
        title: {
          fi: "Minkälaisessa elämänvaiheessa asukkaat ovat?",
          sv: "I vilket skede av livet befinner de boende sig?",
          en: "What stage of life are the residents in?"
        },
        source: area_info[:activity][:source],
        data: {
          icon: "traveler",
          slices: data.map do |item, value|
            {
              label: (
                case item
                when "work"
                  { fi: "Työikäisiä", sv: "Arbetsför ålder", en: "Working age" }
                when "pension_others"
                  { fi: "Eläkeläiset ja muut", sv: "Pensionärer och andra", en: "Pensioners and others" }
                when "children"
                  { fi: "0-14 -vuotiaat", sv: "0-14 åringar", en: "0-14 year olds" }
                when "students_duty"
                  { fi: "Opiskelijat, varus- ja siviilipalvelu", sv: "Studenter, militär och civiltjänst", en: "Students, military and civil service" }
                else
                  raise "Unknown activity data key: #{item}"
                end
              ),
              value: value.to_f
            }
          end
        }
      )
    end

    area_info[:household][:data].each do |key, data|
      Decidim::Insights::AreaDetail.create!(
        area: data_mapping[:areas][key],
        position: 2,
        sticky: true,
        detail_type: "donut",
        title: {
          fi: "Miten täällä asutaan?",
          sv: "Hur bor folk här?",
          en: "How people live here?"
        },
        source: area_info[:household][:source],
        data: {
          icon: "home-smoke",
          slices: data.map do |item, value|
            {
              label: (
                case item
                when "1"
                  { fi: "1 henkilö per asuinkunta", sv: "1 person per hushåll", en: "1 person per household" }
                else
                  { fi: "#{item} hlö", sv: "#{item} pers.", en: "#{item} ppl." }
                end
              ),
              value: value
            }
          end
        }
      )
    end

    area_info[:language][:data].each do |key, data|
      Decidim::Insights::AreaDetail.create!(
        area: data_mapping[:areas][key],
        position: 3,
        sticky: true,
        detail_type: "table",
        title: {
          fi: "Mitä kieliä puhutaan?",
          sv: "Vilka språk talas?",
          en: "What languages are spoken?"
        },
        source: area_info[:language][:source],
        data: data.map do |lang, value|
          {
            label: (
              case lang
              when "xx"
                { fi: "Muu/tuntematon", sv: "Annat/okänt", en: "Other/unknown" }
              else
                %w(fi sv en).to_h do |lkey|
                  [lkey.to_sym, I18n.t("languages.#{lang}", locale: lkey).capitalize]
                end
              end
            ),
            value: value
          }
        end
      )
    end

    area_info[:findings].each do |area, data|
      Decidim::Insights::AreaDetail.create!(
        area: data_mapping[:areas][area],
        position: 4,
        sticky: true,
        detail_type: "iconslist",
        title: {
          fi: "Viisi löytöä alueelta",
          sv: "Fem upptäckter från området",
          en: "Five discoveries from the area"
        },
        data: data
      )
    end

    culture_and_leisure_info.each do |area, info|
      pos = 4
      info.each do |detail|
        pos += 1
        Decidim::Insights::AreaDetail.create!(
          area: data_mapping[:areas][area],
          position: pos,
          sticky: true,
          detail_type: detail[:type],
          title: detail[:title],
          data: detail[:data]
        )
      end
    end

    # The theme data, i.e. column graphs, bar graphs, info boxes, comment boxes
    # and numbered lists categorized for each theme and area
    pos = 7
    # Track the categories to define the sticky items (2 per category)
    card_positions = {}
    starting_positions = {
      "culture" => 50,
      "learning" => 20,
      "environment" => 40,
      "nature" => 30,
      "ecofriendliness" => 70,
      "outdoors" => 0,
      "community" => 10,
      "health" => 60
    }
    sticky_categories = %(outdoors community learning nature environment)
    parse_theme_info(files[:info]).each do |info|
      card_positions[info[:area]] ||= starting_positions.dup

      sticky = false
      category_position = card_positions[info[:area]][info[:category]] - starting_positions[info[:category]]
      if category_position < 2
        sticky = sticky_categories.include?(info[:category])
        sticky = category_position < 1 if sticky && info[:area] == "southeastern" && (info[:category] == "community" || info[:category] == "health")
      end

      pos += 1
      Decidim::Insights::AreaDetail.create!(
        area: data_mapping[:areas][info[:area]],
        category: data_mapping[:categories][info[:category]],
        position: card_positions[info[:area]][info[:category]],
        sticky: sticky,
        detail_type: info[:type],
        title: info[:title],
        source: info[:source],
        data: {
          scale: 100,
          items: info[:values].each_with_index.map do |value, idx|
            {
              label: info[:labels][idx],
              value: (100 * value).round
            }
          end
        }
      )

      card_positions[info[:area]][info[:category]] += 1
    end

    # Track the categories to define the sticky items (1 per category)
    view_amounts = {}
    parse_views_info(files[:views]).each do |info|
      card_positions[info[:area]] ||= starting_positions.dup
      view_amounts[info[:area]] ||= {}
      view_amounts[info[:area]][info[:category]] ||= 0

      sticky = false
      category_position = card_positions[info[:area]][info[:category]] - starting_positions[info[:category]]
      if category_position < 1
        sticky = sticky_categories.include?(info[:category])
        sticky = info[:category] == "health" if !sticky && info[:area] == "southeastern"
      elsif info[:category] == "outdoors"
        sticky = view_amounts[info[:area]][info[:category]] < 1
      end

      pos += 1

      Decidim::Insights::AreaDetail.create!(
        area: data_mapping[:areas][info[:area]],
        category: data_mapping[:categories][info[:category]],
        position: card_positions[info[:area]][info[:category]],
        sticky: sticky,
        detail_type: info[:type],
        title: info[:title],
        source: info[:source],
        data: info[:data]
      )

      card_positions[info[:area]][info[:category]] += 1
      view_amounts[info[:area]][info[:category]] += 1
    end

    # Process the plans data
    puts "Processing plans, this will take a while..."
    geocoder = Decidim::Map.geocoding(organization: organization)
    parse_plans(files[:info]).each_with_index do |data, idx|
      puts " -- #{idx + 1}: #{data[:title][:fi]}"

      description = data[:description]
      data[:source].each do |lang, source|
        next if source.blank?

        source_text = source
        source_text = "https://kartta.hel.fi" if source == "kartta.hel.fi"
        source_text = %(<a href="#{source_text}" target="_blank">#{source_text}</a>) if source_text.match?(%r{^https?://})

        description[lang] = "#{description[lang]}<p>#{source_text}</p>" if source.present?
      end

      plan = Decidim::Insights::AreaPlan.create!(
        area: data_mapping[:areas][data[:area]],
        category: data_mapping[:categories][data[:category]],
        scope: data_mapping[:scopes][data[:scope]],
        title: data[:title],
        summary: data[:summary],
        description: description
      )

      if data[:location]
        plan.locations.create!(
          address: geocoder.address(data[:location]),
          latitude: data[:location][0],
          longitude: data[:location][1]
        )
      end

      if data[:image_url]
        image_uri = URI.parse(data[:image_url])
        download(image_uri) do |io, filename|
          plan.image.attach(io: io, filename: filename)
        end
      end
      next if data[:attachment_urls].blank?

      data[:attachment_urls].each_with_index do |url, weight|
        attachment_uri = URI.parse(url)
        download(attachment_uri, cache: true) do |io, filename, content_type|
          Decidim::Attachment.create(
            title: { fi: filename },
            weight: weight,
            attached_to: plan,
            file: { io: io, filename: filename },
            content_type: content_type
          )
        end
      end
    end
  end

  # Clears the inserted data to be able to re-run the import
  task :clear, [:organization_id] => [:environment] do |_t, args|
    organization = Decidim::Organization.find(args[:organization_id])
    section = Decidim::Insights::Section.find_by(organization: organization, slug: "areas")
    unless section
      puts "The areas section does not exist for the organization."
      next
    end

    section.areas.destroy_all
    section.categories.destroy_all
    Decidim::Locations::Location.where(decidim_locations_locatable_type: "Decidim::Insights::AreaPlan").destroy_all

    %w(decidim_insights_areas decidim_insights_area_plans decidim_insights_area_details).each do |table|
      Decidim::Insights::Section.connection.execute(
        Arel.sql("ALTER SEQUENCE #{table}_id_seq RESTART WITH 1")
      )
    end
  end

  private

  # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def download(uri, cache: false)
    cache_path = Rails.root.join("tmp/downloads_cache")
    FileUtils.mkdir_p(cache_path) unless File.directory?(cache_path)
    @cached_files ||= {}
    cache_hash = Digest::MD5.hexdigest(uri.to_s)
    if cache && @cached_files[cache_hash]
      copy = @cached_files[cache_hash]
      yield File.open(copy[:path]), copy[:filename], copy[:content_type]
      return
    end

    Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https") do |http|
      request = Net::HTTP::Get.new(uri)

      http.request(request) do |response|
        # The requests that doe not have the "Content-Disposition" header are
        # empty responses with no data from the content hub server.
        content_type = response["Content-Type"].split(";").first

        if response.code == "200" && content_type != "text/html"
          disposition = nil
          if response["Content-Disposition"]
            disposition = response["Content-Disposition"].split(";")[1..-1].to_h do |val|
              val.strip.split("=").map(&:strip)
            end
          end

          filename =
            if disposition
              disposition["filename"]
            else
              File.basename(uri.path)
            end

          Tempfile.create("download", binmode: true) do |io|
            response.read_body { |chunk| io.write(chunk) }
            io.rewind

            yield io, filename, content_type

            if cache
              io.rewind

              path = cache_path.join(cache_hash)
              IO.copy_stream(io, path)

              @cached_files[cache_hash] = { path: path, filename: filename, content_type: content_type }
            end
          end
        end
      end
    end
  end
  # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

  def area_slug(area_name)
    {
      "Kaakkoinen" => "southeastern",
      "Pohjoinen" => "northern",
      "Koillinen" => "northeastern",
      "Itäinen" => "easternosternsundom",
      "Läntinen" => "western",
      "Keskinen" => "central",
      "Eteläinen" => "southern"
    }[area_name&.strip]
  end

  def category_key(category_name)
    {
      "Kulttuuri" => "culture",
      "Oppiminen ja osaaminen" => "learning",
      "Rakennettu ympäristö" => "environment",
      "Puistot ja luonto" => "nature",
      "Ekologisuus" => "ecofriendliness",
      "Liikunta ja ulkoilu" => "outdoors",
      "Yhteisöllisyys" => "community",
      "Terveys ja hyvinvointi" => "health"
    }[category_name&.strip]
  end

  # rubocop:disable Metrics/CyclomaticComplexity
  def parse_area_info(file)
    workbook = RubyXL::Parser.parse(file)
    sheets = [:areas, :categories, :sectors, :population, :activity, :household, :language, :findings]

    {}.tap do |data|
      sheets.each_with_index do |sheet, idx|
        worksheet = sheet(workbook.worksheets[idx])

        case sheet
        when :areas, :categories, :sectors
          data[sheet] = []

          columns = worksheet[0]
          worksheet[1..-1].each do |row|
            data[sheet] << {}
            columns.each_with_index do |col, cidx|
              data[sheet][-1][col] = row[cidx]
            end
          end
        when :findings
          data[sheet] = {}
          worksheet[1..-1].each do |row|
            data[sheet][row[0]] ||= []
            data[sheet][row[0]] << {
              icon: row[1],
              label: {
                fi: row[3],
                sv: row[4],
                en: row[5]
              }
            }
          end
        else
          # Statistics data for each area
          data[sheet] = { data: {} }
          if sheet == :household
            data[sheet][:source] = {
              fi: "Tilastokeskus",
              sv: "Statistikcentralen",
              en: "Statistics Finland"
            }
          end

          categories = worksheet[0][1..-1]
          worksheet[1..-1].each do |row|
            data[sheet][:data][row[0]] = {}
            categories.each_with_index do |cat, cidx|
              data[sheet][:data][row[0]][cat.to_s] = row[cidx + 1].to_i
            end
          end
        end
      end
    end
  end
  # rubocop:enable Metrics/CyclomaticComplexity

  def culture_and_leisure_info
    # The common info is the same for all areas
    common = [
      {
        type: "numbers",
        title: {
          fi: "Kulttuurin ja vapaa-ajan palvelut koko Helsingin alueella",
          sv: "Kultur- och fritidstjänster i hela Helsingforsområdet",
          en: "Culture and leisure services in the entire Helsinki area"
        },
        data: [
          {
            value: 800,
            label: {
              fi: "Liikuntapaikkaa",
              sv: "Idrottsanläggningar",
              en: "Sports facilities"
            }
          },
          {
            value: 150,
            label: {
              fi: "Ulkoliikuntapaikkaa",
              sv: "Utegym",
              en: "Outdoor exercise areas"
            }
          },
          {
            value: 70,
            label: {
              fi: "Erilaista tilaa nuorille",
              sv: "Annorlunda utrymmen för ungdomar",
              en: "Different spaces for young people"
            }
          },
          {
            value: 37,
            label: {
              fi: "Kirjastoa",
              sv: "Biblioteket",
              en: "Libraries"
            }
          },
          {
            value: 5,
            label: {
              fi: "Kulttuurikeskusta",
              sv: "Kulturhus",
              en: "Cultural centres"
            }
          },
          {
            value: 1,
            label: {
              fi: "Kaupunginorkesteri",
              sv: "Stadsorkestern",
              en: "Helsinki Philharmonic Orchestra"
            }
          }
        ]
      },
      {
        type: "number",
        title: {
          fi: "Kulttuurin ja vapaa-ajan käynnit koko Helsingin alueella",
          sv: "Kultur- och fritidsbesök i hela Helsingforsområdet",
          en: "Culture and leisure visits in the entire Helsinki area"
        },
        data: {
          value: 23_000_000,
          label: {
            fi: "asiakaskäyntiä vuodessa",
            sv: "kundbesök per år",
            en: "visits per year"
          }
        }
      }
    ]

    {
      "southeastern" => [
        {
          type: "comments",
          title: {
            fi: "Kulttuurin ja vapaa-ajan vinkit",
            sv: "Tips för kultur och fritid",
            en: "Culture and leisure tips"
          },
          data: [
            {
              fi: "Hertsin nuorisotila auki joka päivä",
              sv: "Hertsi ungdomsgård öppen varje dag",
              en: "Hertsi Youth Centre open every day"
            },
            {
              fi: "Kruununvuorenrannan liikuntapuisto avattu 2023",
              sv: "Kronbergsstrandens idrottspark öppnad 2023",
              en: "Kruunuvuorenranta sports park opened in 2023"
            },
            {
              fi: "Herttoniemen kirjasto 195&nbsp;000 käyntiä vuodessa",
              sv: "Hertonäs bibliotek, 195&nbsp;000 besök per år",
              en: "Herttoniemi Library, 195,000 visits per year"
            }
          ]
        },
        *common
      ],
      "northern" => [
        {
          type: "comments",
          title: {
            fi: "Kulttuurin ja vapaa-ajan vinkit",
            sv: "Tips för kultur och fritid",
            en: "Culture and leisure tips"
          },
          data: [
            {
              fi: "Fallkullan kotieläintila",
              sv: "Fallkulla husdjursgård",
              en: "Fallkulla Domestic Animal Farm"
            },
            {
              fi: "Pirkkolan liikuntapuiston ja Paloheinän ulkoilualueet",
              sv: "Friluftsområdena vid Britas idrottspark och i Svedängen",
              en: "Pirkkola sports park and Paloheinä outdoor recreation areas"
            },
            {
              fi: "Oulunkylän kirjasto, 135&nbsp;000 käyntiä vuodessa",
              sv: "Åggelby bibliotek, 135&nbsp;000 besök per år",
              en: "Oulunkylä Library, 135,000 visits per year"
            }
          ]
        },
        *common
      ],
      "northeastern" => [
        {
          type: "comments",
          title: {
            fi: "Kulttuurin ja vapaa-ajan vinkit",
            sv: "Tips för kultur och fritid",
            en: "Culture and leisure tips"
          },
          data: [
            {
              fi: "Tattarisuon moottorihalli",
              sv: "Tattarmossens motorhall",
              en: "Tattarisuo Motors Hall"
            },
            {
              fi: "Ala-Malmin liikuntapuisto",
              sv: "Nedre Malms idrottspark",
              en: "Ala-Malmi sports park"
            },
            {
              fi: "Malmin kirjasto, 200&nbsp;000 käyntiä vuodessa",
              sv: "Malms bibliotek, 200&nbsp;000 besök per år",
              en: "Malmi Library, 200,000 visits per year"
            }
          ]
        },
        *common
      ],
      "easternosternsundom" => [
        {
          type: "comments",
          title: {
            fi: "Kulttuurin ja vapaa-ajan vinkit",
            sv: "Tips för kultur och fritid",
            en: "Culture and leisure tips"
          },
          data: [
            {
              fi: "Suomen suurin sisäskeittihalli Kontulassa",
              sv: "Finlands största inomhusskejthall i Gårdsbacka",
              en: "Finland's largest indoor skatepark in Kontula"
            },
            {
              fi: "Alueliikunta Mellunkylässä ja Vuosaaressa",
              sv: "Områdesmotion i Mellungsby och Nordsjö",
              en: "Regional exercise services in Mellunkylä and Vuosaari"
            },
            {
              fi: "Kontulan kirjasto, 135&nbsp;000 käyntiä vuodessa",
              sv: "Gårdsbacka bibliotek, 135&nbsp;000 besök per år",
              en: "Kontula Library, 135,000 visits per year"
            }
          ]
        },
        *common
      ],
      "western" => [
        {
          type: "comments",
          title: {
            fi: "Kulttuurin ja vapaa-ajan vinkit",
            sv: "Tips för kultur och fritid",
            en: "Culture and leisure tips"
          },
          data: [
            {
              fi: "Talin liikuntapuisto yksi suosituimmista liikuntapuistoista",
              sv: "Tali idrottspark en av de mest populära idrottsparkerna",
              en: "Tali sports park, one of the most popular sports parks"
            },
            {
              fi: "Malminkartanon harrastushalli",
              sv: "Malmgårds fritidshall",
              en: "Malminkartano Recreation Hall"
            },
            {
              fi: "Etelä-Haagan kirjasto, 130&nbsp;000 käyntiä vuodessa",
              sv: "Södra Haga bibliotek, 130&nbsp;000 besök per år",
              en: "Etelä-Haaga Library, 130,000 visits per year"
            }
          ]
        },
        *common
      ],
      "central" => [
        {
          type: "comments",
          title: {
            fi: "Kulttuurin ja vapaa-ajan vinkit",
            sv: "Tips för kultur och fritid",
            en: "Culture and leisure tips"
          },
          data: [
            {
              fi: "Käpylän liikuntapuisto",
              sv: "Kottby idrottspark",
              en: "Käpylä sports park"
            },
            {
              fi: "Kumpulan koulukasvitarha",
              sv: "Gumtäkt skolköksträdgård",
              en: "Kumpula School Garden"
            },
            {
              fi: "Pasilan kirjasto, 166&nbsp;000 käyntiä vuodessa",
              sv: "Böle bibliotek, 166&nbsp;000 besök per år",
              en: "Pasila Library, 166,000 visits per year"
            }
          ]
        },
        *common
      ],
      "southern" => [
        {
          type: "comments",
          title: {
            fi: "Kulttuurin ja vapaa-ajan vinkit",
            sv: "Tips för kultur och fritid",
            en: "Culture and leisure tips"
          },
          data: [
            {
              fi: "Nuorten oma tila Oodissa",
              sv: "Ungdomarnas eget utrymme i Ode",
              en: "Young people's own space at Oodi"
            },
            {
              fi: "Hietsun ulkokuntosali, Jätkäsaaren liikuntapuisto",
              sv: "Utegymmet vid Sandstrands badstrand, Busholmens idrottspark",
              en: "Hietsu outdoor gym, Jätkäsaari sports park"
            },
            {
              fi: "Oodi, 1,8 miljoonaa käyntiä vuodessa",
              sv: "Ode, 1,8 miljoner besök per år",
              en: "Oodi, 1.8 million visits per year"
            }
          ]
        },
        *common
      ]
    }
  end

  # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def parse_theme_info(file)
    workbook = RubyXL::Parser.parse(file)

    # The title translations are missing from the original data
    title_translations = {
      "Vähintään tunnin päivässä liikkuvat" => {
        sv: "Rör på sig minst en timme per dag",
        en: "At least an hour of daily physical activity"
      },
      "Liikunnan harrastaminen ohjatusti viikoittain" => {
        sv: "Utövar ledd motion varje vecka",
        en: "Weekly engagement in guided physical activity"
      },
      "Liikunnan harrastaminen omatoimisesti viikoittain" => {
        sv: "Utövar motion på egen hand varje vecka",
        en: "Weekly independent engagement in leisure time physical activity"
      },
      "Terveysliikuntasuosituksen täyttäminen" => {
        sv: "Uppfyller rekommendationerna om hälsomotion",
        en: "Meeting the recommendation on health-enhancing physical activity"
      },
      "Itsensä kokeminen tärkeäksi osaksi kouluyhteisöä" => {
        sv: "Känner sig som en viktig del av skolgemenskapen",
        en: "Feeling an important part of the school community"
      },
      "Koulu-uupumuksen kokemus" => {
        sv: "Upplevelse av skoltrötthet",
        en: "Experience of school burnout"
      },
      "Koulukiusaamisen yleisyys 4.–5.-luokkalaisilla" => {
        sv: "Utbredning av mobbning i årskurs 4 och 5",
        en: "Prevalence of bullying at school among 4th and 5th graders"
      },
      "Koulunkäynnin mielekkyys 4.–5.-luokkalaisilla" => {
        sv: "Utmaningar med skolgången i årskurs 4 och 5",
        en: "School meaningfulness among 4th and 5th graders"
      },
      "Koulunkäynnin mielekkyys ja haasteet 8.–9.-luokkalaisilla" => {
        sv: "Utmaningar med skolgången och skolgångens meningsfullhet i årskurs 8 och 9",
        en: "School challenges/meaningfulness among 8th and 9th graders"
      },
      "Koulunkäynnin mielekkyys ja haasteet lukiolaisilla" => {
        sv: "Utmaningar med skolgången och skolgångens meningsfullhet bland gymnasieelever",
        en: "School challenges/meaningfulness among upper secondary school students"
      },
      "Koulunkäynnin mielekkyys ja haasteet ammatillisissa oppilaitoksissa" => {
        sv: "Utmaningar med skolgången och skolgångens meningsfullhet i yrkesläroanstalter",
        en: "School challenges/meaningfulness in vocational institutions"
      },
      "Lasten liikkumissuositusten täyttyminen" => {
        sv: "Uppfyllande motionsrekommendationerna för barn",
        en: "Accomplishment of children’s physical activity recommendations"
      },
      "Nuorten liikunnan harrastaminen ohjatusti" => {
        sv: "Utövning av ledd motion på fritiden för ungdomar",
        en: "Youth engagement in guided physical activity in their leisure time"
      },
      "Nuorten liikunnan harrastaminen omatoimisesti" => {
        sv: "Utövning av motion på egen hand för ungdomar",
        en: "Youth engagement in leisure time physical activity"
      },
      "Liikuntasuosituksen täyttävät aikuiset ja ikääntyneet" => {
        sv: "Vuxna och äldre som uppfyller rekommendationerna om hälsomotion",
        en: "Adults and the elderly who meet the recommendation on health-enhancing physical activity"
      },
      "Lasten ja nuorten liikkuminen" => {
        sv: "Motion bland barn och ungdomar",
        en: "Physical activity of children and young people"
      },
      "Yksinäisyyden tunne ikäryhmittäin" => {
        sv: "Känsla av ensamhet enligt åldersgrupp",
        en: "Feeling of loneliness by age group"
      },
      "Aktiivisuus ikäryhmittäin" => {
        sv: "Aktivitet enligt åldersgrupp",
        en: "Activity by age group"
      },
      "Tärkeimmät syyt, jotka estävät nuorten harrastamisen" => {
        sv: "De viktigaste orsakerna som förhindrar ungdomarnas deltagande i hobbyer",
        en: "Three main factors preventing young people from engaging in recreational activities"
      },
      "Lasten ja nuorten harrastaminen" => {
        sv: "Barns och ungas utövande av hobbyer",
        en: "Recreational activities among children and young people"
      }
    }
    label_translations = {
      "2. aste" => {
        sv: "Andra stadiet",
        en: "Upper secondary"
      },
      "4.–5. luokka" => {
        sv: "Årskurs 4-5",
        en: "4th-5th grade"
      },
      "8.–9. luokka" => {
        sv: "Årskurs 8-9",
        en: "8th-9th grade"
      },
      "Aikuiset" => {
        sv: "Vuxna",
        en: "Adults"
      },
      "Nuoret" => {
        sv: "Ungdomar",
        en: "Young people"
      },
      "Vanhukset" => {
        sv: "Äldre",
        en: "Older people"
      },
      "20–74 v" => {
        sv: "20–74 år",
        en: "20–74 yrs"
      },
      "Yli 75 v" => {
        sv: "Över 75 år",
        en: "> 75 yrs"
      },
      "Ei tiedä alueensa harrastusmahdollisuuksista" => {
        sv: "Känner inte till hobbymöjligheterna i det egna området",
        en: "Unaware of the recreational opportunities in their area"
      },
      "Kokee harrastuspaikkojen olevan liian kaukana" => {
        sv: "Upplever att hobbyplatserna är för långt borta",
        en: "Think that recreational facilities are located too far away"
      },
      "Kokee kiinnostavan harrastuksen liian kalliiksi" => {
        sv: "Upplever att en intressant hobby är för dyr",
        en: "Think that an interesting hobby is too expensive"
      },
      "Kokee vaikeuksia lukemista vaativissa tehtävissä" => {
        sv: "Har svårigheter med uppgifter som kräver läsning",
        en: "Have difficulties in tasks that require reading skills"
      },
      "Kokee vaikeuksia läksyjen tekemisessä" => {
        sv: "Har svårigheter med läxorna",
        en: "Have difficulties in doing their homework"
      },
      "Liikuntaa viikoittain ohjatusti harrastavat nuoret" => {
        sv: "Ungdomar som idrottar organiserat varje vecka",
        en: "Young people who engage in guided physical activity weekly"
      },
      "On koulukiusattuna vähintään kerran viikossa" => {
        sv: "Utsätts för mobbning minst en gång i veckan",
        en: "Experiencing bullying at school at least once a week"
      },
      "Pitää koulunkäynnistä" => {
        sv: "Gillar skolan",
        en: "Like going to school"
      },
      "Vapaa-ajalla vähintään viikoittain liikkuvat nuoret" => {
        sv: "Ungdomar som rör på sig på fritiden minst varje vecka",
        en: "Young people engaging in an organised physical activity at least once a week"
      },
      "Vähintään tunnin päivässä liikkuvat lapset" => {
        sv: "Barn som rör på sig minst en timme per dag",
        en: "Children with at least an hour of daily physical activity"
      },
      "Vähintään tunnin päivässä liikkuvat nuoret" => {
        sv: "Ungdomar som rör på sig minst en timme per dag",
        en: "Young people with at least an hour of daily physical activity"
      },
      "Vähintään viikoittain kulttuuria tai taidetta harrastavat nuoret" => {
        sv: "Ungdomar har en kultur- eller konsthobby åtminstone en gång i veckan",
        en: "Young people who engage in culture or art at least weekly"
      },
      "Vähintään yhtenä päivänä viikossa harrastavat lapset" => {
        sv: "Barn med en hobby minst en dag i veckan",
        en: "Children who engage in a hobby at least on one day a week"
      }
    }

    sheet(workbook.worksheets[0])[2..-1].map do |row|
      next if row[0].blank?

      type = row[3].to_i == 1 ? "column" : "bar"

      labels = [8, 12, 16].map { |idx| row[idx].strip }.select(&:present?)
      values = [6, 10, 14].map { |idx| row[idx].to_f }[0..(labels.length - 1)]

      title = row[4].strip
      {
        area: area_slug(row[0]),
        category: category_key(row[1]),
        type: type,
        dataset: {
          fi: row[2],
          sv: row[2 + 22],
          en: row[2 + 22 + 9]
        },
        title: {
          fi: title,
          sv: title_translations[title][:sv],
          en: title_translations[title][:en]
        },
        labels: (
          labels.map do |label|
            {
              fi: label,
              sv: label_translations[label][:sv],
              en: label_translations[label][:en]
            }
          end
        ),
        values: values,
        source: {
          fi: (row[20] || "").split(",").first.presence,
          sv: (row[20 + 10] || "").split(",").first.presence,
          en: (row[20 + 10 + 9] || "").split(",").first.presence
        }
      }
    end.compact
  end
  # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

  def parse_views_info(file)
    workbook = RubyXL::Parser.parse(file)

    sheet(workbook.worksheets[0])[1..-1].map do |row|
      next if row[0].blank?

      type =
        case row[2].to_i
        when 1
          "numberedlist"
        when 2
          "info"
        else
          "comment"
        end

      current = [6, 9, 12].map do |idx|
        {
          fi: row[idx],
          sv: row[idx + 1],
          en: row[idx + 2]
        }
      end

      base_data = {
        type: type,
        area: area_slug(row[0]),
        category: category_key(row[1]),
        title: {
          fi: row[3],
          sv: row[4],
          en: row[5]
        },
        source: {
          fi: row[15],
          sv: row[16],
          en: row[17]
        }
      }

      case type
      when "numberedlist"
        base_data.merge(data: current.reject { |item| item[:fi].blank? })
      when "info"
        base_data.merge(data: current[0])
      else
        # No title for comments
        base_data.delete(:title)
        base_data.merge(data: current[0])
      end
    end
  end

  # rubocop:disable Metrics/CyclomaticComplexity
  def parse_plans(file)
    workbook = RubyXL::Parser.parse(file)

    sheet(workbook.worksheets[4])[2..-1].map do |row|
      next if row[0].blank?

      attachments = nil
      attachments_cell = row[9].try(:strip)
      attachments = attachments_cell.gsub(/\r?\n/, "").split("https://").map(&:strip).reject(&:blank?).map { |url| "https://#{url}" } if attachments_cell.present?

      title = {
        fi: text_formatter.title(row[3]),
        sv: text_formatter.title(row[3 + 11]),
        en: text_formatter.title(row[3 + 11 + 7])
      }
      summary = {
        fi: text_formatter.summary(row[4]),
        sv: text_formatter.summary(row[4 + 11]),
        en: text_formatter.summary(row[4 + 11 + 7])
      }
      description = {
        fi: text_formatter.description(row[5]),
        sv: text_formatter.description(row[5 + 11]),
        en: text_formatter.description(row[5 + 11 + 7])
      }
      location = latlng(row[7], row[8])

      # Fix mistakes in the source data
      case title[:fi]
      when "Mustikkamaan uimarannalle polkupyöäparkki"
        title[:fi] = "Mustikkamaan uimarannalle polkupyöräparkki"
        location = [60.178940, 24.992589]
      when "Meilahden liikuntapuiston huoltorakennuksen ja pukutilan kunnostaminen"
        location = [60.190262, 24.898205]
      when "Helsingin hyvinvointisuunnitelma 2022–2025"
        title = {
          fi: "#{text_formatter.title(summary[:fi])} (#{title[:fi]})",
          sv: "#{text_formatter.title(summary[:sv])} (#{title[:sv]})",
          en: "#{text_formatter.title(summary[:en])} (#{title[:en]})"
        }
        summary = { fi: "", sv: "", en: "" }
      end

      {
        area: area_slug(row[0]),
        category: category_key(row[1]),
        scope: row[2].try(:upcase),
        title: title,
        summary: summary,
        description: description,
        image_url: row[6].try(:strip),
        location: location,
        attachment_urls: attachments,
        source: {
          fi: text_formatter.title(row[10]),
          sv: text_formatter.title(row[10 + 7]),
          en: text_formatter.title(row[10 + 7 + 7])
        }
      }
    end.compact
  end
  # rubocop:enable Metrics/CyclomaticComplexity

  def text_formatter
    @text_formatter ||= Class.new do
      include ActionView::Helpers::TextHelper

      def title(text)
        return text unless text.respond_to?(:strip)

        text.gsub(/\n/, " ").gsub(/\s+/, " ").strip.sub(/\.$/, "")
      end

      def summary(text)
        return text unless text.respond_to?(:strip)

        text.gsub(/\n/, " ").gsub(/\s+/, " ").strip
      end

      def description(text)
        return text unless text.respond_to?(:strip)

        # Replace single newlines from the body text with spaces to avoid adding
        # unnecessary line breaks to the text. Double line breaks should convert
        # to paragraph breaks.
        body = text.strip.gsub(/\r/, "").gsub(/[^\n]\n[^\n]/, " ").gsub("  ", " ")

        simple_format(body)
      end
    end.new
  end

  def latlng(latitude, longitude)
    return if latitude.blank? || longitude.blank?
    return if latitude.strip.blank? || longitude.strip.blank?

    [latitude.to_f, longitude.to_f]
  end

  def sheet(sheet)
    sheet.map { |row| row && row.cells.map { |c| c.try(:value) } }.compact
  end
end
