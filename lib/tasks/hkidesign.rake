# frozen_string_literal: true

namespace :hkidesign do
  # Takes in the path to the cloned HDS repository from:
  # https://github.com/City-of-Helsinki/helsinki-design-system
  #
  # Note that this script assumes the icons to be located within the following
  # subfolder of that path: packages/core/src/svg/ui
  desc "Create the icons pack from the Helsinki design assets."
  task :create_icons, [:hds_path] do |_t, args|
    icons_dir = "#{args[:hds_path]}/packages/core/src/svg"
    unless File.directory?(icons_dir)
      puts "The following folder does not exist: #{icons_dir}"
      next
    end

    target_path = File.expand_path("../../app/packs/images/helsinki/helsinki-icons.svg", __dir__)
    if File.exist?(target_path)
      puts "The target icons file exists. Do you want to override it? (y/n)"
      confirm = $stdin.gets.chomp.downcase
      if confirm != "y"
        puts "Icons conversion aborted."
        next
      end
    end

    # To be used as a fallback for the icons that do not have an equivalent
    # defined. Those icons have equivalent marked as `nil` in the mapping.
    original_set_path = "#{Gem.loaded_specs["decidim-core"].full_gem_path}/app/packs/images/decidim/icons.svg"
    original_set = Nokogiri::XML.parse(File.read(original_set_path))
    original_icons = original_set.css("symbol").collect.to_h do |node|
      [node["id"].sub(/^icon-/, "").to_sym, { content: node.inner_html, attributes: { "viewBox" => node["viewBox"] } }]
    end

    # Maps the original Decidim icon names to HDS icon equivalents.
    # Decidim icons set (up to 0.27): https://github.com/iconic/open-iconic/tree/master/svg
    # HDS icons: https://hds.hel.fi/foundation/visual-assets/icons/list
    #
    # Some extra icons have been added to the original Decidim icons set on top
    # of the open-ionic icons, such as component and participatory space icons.
    # Those icons should not visible anywhere in the participant-facing UI.
    #
    # Note that not all icons have a corresponding equivalent in which case the
    # replacement is marked as `nil` and the original icon will be used in the
    # final SVG.
    #
    # To get the list of Decidim icons, you can use the following (bash) command:
    # grep -oPm1 '(?<=<symbol id=")[^"]+' $(bundle show decidim-core)/app/packs/images/decidim/icons.svg
    icons_mapping = {
      "account-login": "signin",
      "account-logout": "signout",
      "action-redo": "arrow-redo",
      "action-undo": "arrow-undo",
      actions: "check-circle",
      "align-center": nil,
      "align-left": nil,
      "align-right": nil,
      aperture: nil,
      "arrow-bottom": "arrow-down",
      "arrow-circle-bottom": "arrow-down",
      "arrow-circle-left": "arrow-left",
      "arrow-circle-right": "arrow-right",
      "arrow-circle-top": "arrow-up",
      "arrow-left": "arrow-left",
      "arrow-right": "arrow-right",
      "arrow-thick-bottom": "arrow-down",
      "arrow-thick-left": "arrow-left",
      "arrow-thick-right": "arrow-right",
      "arrow-thick-top": "arrow-up",
      "arrow-top": "arrow-up",
      "arrow-thin-right": "arrow-right",
      "arrow-thin-up": "arrow-up",
      "arrow-thin-left": "arrow-left",
      "arrow-thin-down": "arrow-down",
      "audio-spectrum": "graph-columns",
      audio: "volume-high",
      badge: "ticket",
      ban: "cross-circle",
      "bar-chart": "graph-columns",
      basket: "trash",
      "battery-empty": nil,
      "battery-full": nil,
      beaker: nil,
      bell: "bell",
      bluetooth: nil,
      bold: "text-bold",
      bolt: nil,
      book: "scroll-group",
      bookmark: nil,
      box: "layers",
      briefcase: "occupation",
      "british-pound": nil,
      browser: "display",
      brush: "pen",
      bug: nil,
      bullhorn: "volume-low",
      calculator: nil,
      calendar: "calendar",
      "camera-slr": "camera",
      "caret-bottom": "angle-down",
      "caret-left": "angle-left",
      "caret-right": "angle-right",
      "caret-top": "angle-up",
      cart: "shopping-cart",
      chat: "speechbubble",
      check: "check",
      "chevron-bottom": "angle-down",
      "chevron-left": "angle-left",
      "chevron-right": "angle-right",
      "chevron-top": "angle-up",
      "circle-check": "check-circle-fill",
      "circle-check-old": "check-circle",
      "circle-x": "cross-circle",
      clipboard: "copy",
      clock: "clock",
      "cloud-download": "download-cloud",
      "cloud-upload": "upload-cloud",
      cloud: "download-cloud",
      cloudy: nil,
      code: nil,
      cog: "cogwheel",
      "collapse-down": "angle-down",
      "collapse-left": "angle-left",
      "collapse-right": "angle-right",
      "collapse-up": "angle-up",
      command: "display",
      "comment-square": "speechbubble",
      compass: "locate",
      contrast: nil,
      copywriting: "document",
      "credit-card": nil,
      crop: nil,
      dashboard: "sliders",
      "data-transfer-download": "download",
      "data-transfer-upload": "upload",
      debates: nil,
      delete: "trash",
      dial: "sliders",
      document: "document",
      dollar: nil,
      "double-quote-sans-left": nil,
      "double-quote-sans-right": nil,
      "double-quote-serif-left": nil,
      "double-quote-serif-right": nil,
      droplet: nil,
      eject: "arrow-up",
      elevator: "sort",
      ellipses: "menu-dots",
      "envelope-closed": "envelope",
      "envelope-open": "envelope",
      euro: "glyph-euro",
      excerpt: "document",
      "expand-down": "angle-down",
      "expand-left": "angle-left",
      "expand-right": "angle-right",
      "expand-up": "angle-up",
      # Hel.fi uses arrow-top-right as the external link indicator but this is
      # not according to the HSD documentation.
      "external-link": "link-external",
      eye: "eye",
      eyedropper: "vaccine",
      facebook: "facebook",
      file: "document",
      fire: nil,
      flag: nil,
      flash: nil,
      folder: "layers",
      fork: "sitemap",
      "fullscreen-enter": "sort",
      "fullscreen-exit": "collapse",
      github: nil,
      globe: "globe",
      google: "google",
      graph: "graph-columns",
      "grid-four-up": nil,
      "grid-three-up": nil,
      "grid-two-up": nil,
      "hard-drive": "save-diskette",
      header: nil,
      headphones: "headphones",
      heart: "heart-fill",
      home: "home",
      image: "photo",
      inbox: "speechbubble-text",
      infinity: nil,
      info: "info-circle",
      instagram: "instagram",
      italic: "text-italic",
      "justify-center": nil,
      "justify-left": nil,
      "justify-right": nil,
      key: "key",
      laptop: "display",
      layers: "layers",
      lightbulb: "lightbulb",
      "link-broken": "link",
      "link-intact": "link",
      "list-rich": "menu-hamburger",
      list: "menu-hamburger",
      location: "location",
      "lock-locked": "lock",
      "lock-unlocked": "lock-open",
      "loop-circular": "refresh",
      "loop-square": "refresh",
      loop: "refresh",
      "magnifying-glass": "search",
      "map-marker": "location",
      map: "map",
      "media-pause": "playback-pause",
      "media-play": "playback-play",
      "media-record": "playback-record",
      "media-skip-backward": "playback-rewind",
      "media-skip-forward": "playback-fastforward",
      "media-step-backward": "playback-previous",
      "media-step-forward": "playback-next",
      "media-stop": "playback-stop",
      "medical-cross": nil,
      meetings: nil,
      menu: "menu-hamburger",
      microphone: "microphone",
      minus: "minus",
      monitor: "display",
      moon: nil,
      move: "drag",
      "musical-note": nil,
      paperclip: "paperclip",
      pencil: "pen",
      people: "group",
      person: "user",
      phone: "phone",
      "pie-chart": nil,
      pin: "location",
      "play-circle": "playback-play",
      plus: "plus",
      "power-standby": nil,
      print: "printer",
      process: nil,
      project: "scroll-content",
      pulse: nil,
      "puzzle-piece": nil,
      "question-mark": "question-circle",
      rain: nil,
      random: "refresh",
      reload: "refresh",
      "resize-both": "drag",
      "resize-height": "drag",
      "resize-width": "drag",
      "rss-alt": "rss",
      rss: "rss",
      script: nil,
      "share-boxed": "share",
      share: "share",
      shield: "shield",
      signal: "graph-columns",
      signpost: nil,
      "sort-ascending": "sort-ascending",
      "sort-descending": "sort-descending",
      spreadsheet: "document",
      star: "star",
      sun: nil,
      tablet: nil,
      tag: nil,
      tags: nil,
      target: "locate",
      task: "check-circle",
      terminal: nil,
      text: "text-tool",
      "thumb-down": "thumbs-down",
      "thumb-up": "thumbs-up",
      timer: "clock",
      transfer: nil,
      trash: "trash",
      twitter: "twitter",
      underline: nil,
      "verified-badge": nil,
      "vertical-align-bottom": nil,
      "vertical-align-center": nil,
      "vertical-align-top": nil,
      video: "videocamera",
      "volume-high": "volume-high",
      "volume-low": "volume-low",
      "volume-off": "volume-mute",
      warning: "error-fill",
      wifi: "wifi",
      wrench: "cogwheels",
      x: "cross",
      yen: nil,
      youtube: "youtube",
      "zoom-in": "zoom-in",
      "zoom-out": "zoom-out",
      "random-seed": "refresh",
      "euro-outline": "glyph-euro",
      datetime: "clock",
      members: "group",
      speakers: "group",
      profile: "user",
      # Decidim
      videos: "playback-next",
      consultation: "speechbubble", # space
      sortition: "refresh", # component
      assemblies: "group", # space
      initiatives: "lightbulb", # space
      proposals: "lightbulb", # component
      "proposals-old": nil, # component
      blog: "document", # component
      information: "info-circle-fill" # component
    }
    # These are icons not included in the HDS icons pack but were in the
    # OmaStadi design.
    # rubocop:disable Layout/LineLength
    custom_icons = {
      flag: %(
        <svg role="img" version="1.1" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
          <path d="m3.4102 2v20h2.2871v-10.896h14.838l-3.1113-4.6133 3.168-4.4902z" fill="currentColor"/>
        </svg>
      ),
      # leaf: %(
      #   <svg role="img" version="1.1" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
      #     <path d="m18.344 8.0356c0-1.7961-1.4289-2.5603-2.1963-2.9709-0.16554-0.08853-0.33648-0.17994-0.41187-0.23896-0.18066-0.14143-0.3766-0.43868-0.58407-0.75357-0.57633-0.87449-1.3654-2.0721-3.1514-2.0721-1.8128 0-2.6037 1.2563-3.1269 2.0876-0.19595 0.31129-0.38092 0.60512-0.55294 0.74259-0.07395 0.0592-0.25461 0.15438-0.42933 0.24633-0.78074 0.41133-2.2343 1.1768-2.2343 2.959 0 1.0242 0.52793 1.7144 0.95222 2.269 0.34944 0.45686 0.56374 0.75465 0.56374 1.1028 0 0.24957-0.0977 0.39424-0.31867 0.69761-0.29042 0.39892-0.68825 0.9452-0.68825 1.9075 0 1.6264 1.3632 2.5975 2.6816 3.5365 1.2667 0.9022 2.4633 1.7546 2.4633 3.0825v1.3686h1.3792v-1.3686c0-1.3279 1.1966-2.1803 2.4635-3.0825 1.3182-0.9389 2.6814-1.91 2.6814-3.5365 0-0.96229-0.39784-1.5086-0.68825-1.9075-0.22096-0.30337-0.31849-0.44804-0.31849-0.69761 0-0.34818 0.21412-0.64597 0.56356-1.1028 0.42429-0.55456 0.95222-1.2448 0.95222-2.269m-1.3794 0c0 0.55708-0.30967 0.96212-0.66828 1.431-0.3973 0.51929-0.8475 1.1079-0.8475 1.9408 0 0.70912 0.32316 1.1528 0.58281 1.5095 0.24615 0.3381 0.42393 0.58227 0.42393 1.0956 0 0.91551-0.97417 1.6093-2.1024 2.4129-0.5623 0.40072-1.1523 0.82392-1.6631 1.3128v-1.8765l2.1009-2.1009-0.97543-0.97543-1.1255 1.1257v-2.647l2.6488-2.6486-0.97543-0.97543-1.6734 1.6734v-3.4846h-1.3792v3.4844l-1.6734-1.6732-0.97525 0.97543 2.6486 2.6485v2.6472l-1.1255-1.1257-0.97543 0.97543 2.1009 2.1009v1.8764c-0.51084-0.4887-1.1007-0.91191-1.6631-1.3126-1.1282-0.80341-2.1024-1.4974-2.1024-2.4129 0-0.51336 0.17778-0.75753 0.42393-1.0956 0.25965-0.35663 0.58281-0.80035 0.58281-1.5095 0-0.83292-0.4502-1.4215-0.84732-1.9408-0.35879-0.46891-0.66846-0.87395-0.66846-1.431 0-0.8797 0.64903-1.2916 1.4978-1.7385 0.25299-0.13333 0.47161-0.24831 0.64813-0.38956 0.35357-0.28286 0.59882-0.6726 0.85847-1.085 0.56518-0.89788 0.97921-1.4431 1.9597-1.4431 0.97291 0 1.4044 0.54844 1.9996 1.4517 0.27134 0.41169 0.52757 0.80053 0.886 1.0809 0.1695 0.13279 0.37408 0.24219 0.61106 0.36887 0.83148 0.4448 1.4676 0.85649 1.4676 1.7547" fill="currentColor"/>
      #   </svg>
      # ),
      leaf: %(
        <svg role="img" version="1.1" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
          <path d="m19.612 7.2426c0-2.1553-1.7147-3.0724-2.6356-3.5651-0.19865-0.10624-0.40378-0.21593-0.49424-0.28675-0.21679-0.16972-0.45192-0.52642-0.70088-0.90428-0.69159-1.0494-1.6385-2.4865-3.7817-2.4865-2.1754 0-3.1244 1.5076-3.7523 2.5051-0.23514 0.37355-0.4571 0.72614-0.66353 0.89111-0.08874 0.07104-0.30553 0.18526-0.5152 0.2956-0.93689 0.4936-2.6812 1.4122-2.6812 3.5508 0 1.229 0.63352 2.0573 1.1427 2.7228 0.41933 0.54823 0.67649 0.90558 0.67649 1.3234 0 0.29948-0.11724 0.47309-0.3824 0.83713-0.3485 0.4787-0.8259 1.1342-0.8259 2.289 0 1.9517 1.6358 3.117 3.2179 4.2438 1.52 1.0826 2.956 2.1055 2.956 3.699v1.6423h1.655v-1.6423c0-1.5935 1.4359-2.6164 2.9562-3.699 1.5818-1.1267 3.2177-2.292 3.2177-4.2438 0-1.1547-0.47741-1.8103-0.8259-2.289-0.26515-0.36404-0.38219-0.53765-0.38219-0.83713 0-0.41782 0.25694-0.77516 0.67627-1.3234 0.50915-0.66547 1.1427-1.4938 1.1427-2.7228m-1.6553 0c0 0.6685-0.3716 1.1545-0.80194 1.7172-0.47676 0.62315-1.017 1.3295-1.017 2.329 0 0.85094 0.38779 1.3834 0.69937 1.8114 0.29538 0.40572 0.50872 0.69872 0.50872 1.3147 0 1.0986-1.169 1.9312-2.5229 2.8955-0.67476 0.48086-1.3828 0.9887-1.9957 1.5754v-2.2518l2.5211-2.5211-1.1705-1.1705-1.3506 1.3508v-3.1764l3.1786-3.1783-1.1705-1.1705-2.0081 2.0081v-4.1815h-1.655v4.1813l-2.0081-2.0078-1.1703 1.1705 3.1783 3.1782v3.1766l-1.3506-1.3508-1.1705 1.1705 2.5211 2.5211v2.2517c-0.61301-0.58644-1.3208-1.0943-1.9957-1.5751-1.3538-0.96409-2.5229-1.7969-2.5229-2.8955 0-0.61603 0.21334-0.90904 0.50872-1.3147 0.31158-0.42796 0.69937-0.96042 0.69937-1.8114 0-0.9995-0.54024-1.7058-1.0168-2.329-0.43055-0.56269-0.80215-1.0487-0.80215-1.7172 0-1.0556 0.77883-1.5499 1.7974-2.0862 0.30359-0.16 0.56593-0.29797 0.77775-0.46747 0.42428-0.33943 0.71858-0.80712 1.0302-1.302 0.67821-1.0775 1.1751-1.7317 2.3516-1.7317 1.1675 0 1.6853 0.65813 2.3995 1.742 0.32561 0.49403 0.63308 0.96063 1.0632 1.2971 0.2034 0.15935 0.4489 0.29063 0.73327 0.44264 0.99777 0.53376 1.7611 1.0278 1.7611 2.1056" fill="currentColor"/>
        </svg>
      ),
      bicycle: %(
        <svg version="1.1" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
          <path d="m13.467 4.534-0.53437 1.5984h1.7626c0.61937 0 1.17 0.39667 1.3664 0.98437l0.5625 1.6828h-8.8898l-1.3336 1.9992c-0.57883-0.26219-1.2131-0.39844-1.8679-0.39844-1.2109 0-2.3501 0.4703-3.2063 1.3266-0.85622 0.85622-1.3266 1.9954-1.3266 3.2063 0 1.2109 0.4703 2.3501 1.3266 3.2063 0.85622 0.85622 1.9954 1.3266 3.2063 1.3266 1.2109 0 2.3501-0.4703 3.2063-1.3266 0.66497-0.66497 1.0978-1.5014 1.2586-2.4071h2.1281l0.47578 1.4672h1.5984l-0.47813-1.4813 3.5602-5.3179h0.87422l0.17813 0.52969c-0.39011 0.20772-0.74938 0.47515-1.0711 0.79687-0.85622 0.85622-1.3289 1.9954-1.3289 3.2063s0.4727 2.3501 1.3289 3.2063c0.85622 0.85622 1.9931 1.3266 3.2039 1.3266 1.2108 0 2.3501-0.4703 3.2063-1.3266 0.85622-0.85622 1.3266-1.9954 1.3266-3.2063 0-1.2109-0.4703-2.3501-1.3266-3.2063-0.85622-0.85622-1.9954-1.3266-3.2063-1.3266-0.23432 0-0.46577 0.01845-0.69374 0.05392l-1.3031-3.9141c-0.39898-1.1982-1.5216-2.0063-2.7844-2.0063h-1.2187zm-7.4602 1.5984-0.0047 1.6008h4.1321l-0.53437-1.6008h-3.5929zm2.5852 4.2679h5.7632l-2.2571 3.3868-0.36328-1.1203h-1.6008l0.47578 1.4672h-1.6126c-0.16086-0.90689-0.59125-1.7434-1.2563-2.4071-0.00761-0.0076-0.015838-0.0135-0.023438-0.02109l0.87422-1.3055zm10.875 1.5984c1.6175 0 2.9321 1.3169 2.9321 2.9344s-1.3146 2.9321-2.9321 2.9321v0.0023c-1.6175 0-2.9321-1.3169-2.9321-2.9344 0-1.0209 0.52423-1.9212 1.3172-2.4469l1.0805 3.2461h1.6008l-1.2422-3.7266c0.05827-0.0039 0.11626-7e-3 0.17578-7e-3zm-14.932 0.0023c0.33565 0 0.6584 0.05659 0.9586 0.16172l-1.514 2.2687 0.42187 1.3031h2.9531c-0.34937 1.2292-1.4806 2.1317-2.8195 2.1328h-0.00234c-1.6164-0.0014-2.9321-1.3177-2.9321-2.9344 0-1.6175 1.3169-2.9321 2.9344-2.9321zm2.2664 1.0758c0.2514 0.30743 0.4442 0.66506 0.55547 1.057h-1.2632l0.70781-1.057z" fill="currentColor"/>
        </svg>
      )
    }
    # rubocop:enable Layout/LineLength
    # Extra icons not available in the original set
    extra_icons = {
      bicycle: nil,
      binoculars: "binoculars",
      "calendar-clock": "calendar-clock",
      "info-line": "info-circle",
      "heart-line": "heart",
      "home-smoke": "home-smoke",
      leaf: nil,
      traveler: "traveler"
    }

    final_icons = original_icons.to_h do |key, icon|
      if custom_icons[key]
        replacement = Nokogiri::XML.parse(custom_icons[key], &:noblanks).css("svg").first
        icon = { content: hki_icon_content(replacement), attributes: { "viewBox" => replacement["viewBox"] } }
      elsif icons_mapping[key]
        replace_key = icons_mapping[key].to_sym
        replacement = hki_icon_svg(replace_key, icons_dir)
        icon = { content: hki_icon_content(replacement), attributes: { "viewBox" => replacement["viewBox"] } }
      end

      [key, icon]
    end
    extra_icons.each do |key, icon_key|
      icon_node =
        if custom_icons[key]
          Nokogiri::XML.parse(custom_icons[key], &:noblanks).css("svg").first
        else
          hki_icon_svg(icon_key, icons_dir)
        end
      final_icons[key] = { content: hki_icon_content(icon_node), attributes: { "viewBox" => icon_node["viewBox"] } }
    end

    # Generate the replacement SVG
    builder = Nokogiri::XML::Builder.new do |xml|
      xml.svg("xmlns" => "http://www.w3.org/2000/svg", "display" => "none", "viewBox" => "0 0 100 100") do
        final_icons.each do |key, icon|
          xml.symbol({ "id" => "icon-#{key}" }.merge(icon[:attributes])) do
            xml << icon[:content]
          end
        end
      end
    end
    # raise builder.doc.root.to_xml

    # Replace the target symbols file with the new one
    File.write(target_path, builder.to_xml(save_with: xmlopts))
    puts "Icons written to: #{target_path}"
  end

  def hki_icon_svg(icon, icons_dir)
    candidates = [
      "#{icons_dir}/ui/#{icon}.svg",
      "#{icons_dir}/some/#{icon}.svg"
    ]
    target_icon_path = candidates.find { |path| File.exist?(path) }
    raise "Unable to locate icon:\n  #{candidates.join("\n  ")}" unless target_icon_path

    icon_data = File.read(target_icon_path)
    Nokogiri::XML.parse(icon_data, &:noblanks).css("svg").first
  end

  def hki_icon_content(icon_node)
    icon_node.children.map { |node| node.to_xml(save_with: xmlopts) }.join
  end

  def xmlopts
    Nokogiri::XML::Node::SaveOptions::AS_XML | Nokogiri::XML::Node::SaveOptions::NO_DECLARATION
  end
end
