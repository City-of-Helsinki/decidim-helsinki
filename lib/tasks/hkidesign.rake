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
      book: nil,
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
      command: nil,
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
      star: "star-fill",
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
    # OmaStadi design + needed for the area information pages.
    # rubocop:disable Layout/LineLength
    custom_icons = {
      bicycle: %(
        <svg version="1.1" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
          <path d="m13.467 4.534-0.53437 1.5984h1.7626c0.61937 0 1.17 0.39667 1.3664 0.98437l0.5625 1.6828h-8.8898l-1.3336 1.9992c-0.57883-0.26219-1.2131-0.39844-1.8679-0.39844-1.2109 0-2.3501 0.4703-3.2063 1.3266-0.85622 0.85622-1.3266 1.9954-1.3266 3.2063 0 1.2109 0.4703 2.3501 1.3266 3.2063 0.85622 0.85622 1.9954 1.3266 3.2063 1.3266 1.2109 0 2.3501-0.4703 3.2063-1.3266 0.66497-0.66497 1.0978-1.5014 1.2586-2.4071h2.1281l0.47578 1.4672h1.5984l-0.47813-1.4813 3.5602-5.3179h0.87422l0.17813 0.52969c-0.39011 0.20772-0.74938 0.47515-1.0711 0.79687-0.85622 0.85622-1.3289 1.9954-1.3289 3.2063s0.4727 2.3501 1.3289 3.2063c0.85622 0.85622 1.9931 1.3266 3.2039 1.3266 1.2108 0 2.3501-0.4703 3.2063-1.3266 0.85622-0.85622 1.3266-1.9954 1.3266-3.2063 0-1.2109-0.4703-2.3501-1.3266-3.2063-0.85622-0.85622-1.9954-1.3266-3.2063-1.3266-0.23432 0-0.46577 0.01845-0.69374 0.05392l-1.3031-3.9141c-0.39898-1.1982-1.5216-2.0063-2.7844-2.0063h-1.2187zm-7.4602 1.5984-0.0047 1.6008h4.1321l-0.53437-1.6008h-3.5929zm2.5852 4.2679h5.7632l-2.2571 3.3868-0.36328-1.1203h-1.6008l0.47578 1.4672h-1.6126c-0.16086-0.90689-0.59125-1.7434-1.2563-2.4071-0.00761-0.0076-0.015838-0.0135-0.023438-0.02109l0.87422-1.3055zm10.875 1.5984c1.6175 0 2.9321 1.3169 2.9321 2.9344s-1.3146 2.9321-2.9321 2.9321v0.0023c-1.6175 0-2.9321-1.3169-2.9321-2.9344 0-1.0209 0.52423-1.9212 1.3172-2.4469l1.0805 3.2461h1.6008l-1.2422-3.7266c0.05827-0.0039 0.11626-7e-3 0.17578-7e-3zm-14.932 0.0023c0.33565 0 0.6584 0.05659 0.9586 0.16172l-1.514 2.2687 0.42187 1.3031h2.9531c-0.34937 1.2292-1.4806 2.1317-2.8195 2.1328h-0.00234c-1.6164-0.0014-2.9321-1.3177-2.9321-2.9344 0-1.6175 1.3169-2.9321 2.9344-2.9321zm2.2664 1.0758c0.2514 0.30743 0.4442 0.66506 0.55547 1.057h-1.2632l0.70781-1.057z" fill="currentColor"/>
        </svg>
      ),
      boat: %(
        <svg version="1.1" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
          <path d="m8.5131 23.416c-2.6886-0.40974-6.7833-1.8903-7.5398-2.7262-0.33898-0.37457-0.69664-1.5168-0.79479-2.5384l-0.17847-1.8574 13.721-0.55491v-2.1751h-10.696c-0.51436-0.0012-0.062027-0.32423-0.10849-0.3994 1.1502-1.2621 4.4649-4.6827 6.5033-7.0643 2.246-2.624 3.2159-4.2229 4.2782-5.6788 0.26441-0.23999 0.698-0.38106 1.0723 0.0035038 0 0-0.06128 3.2395-4.07e-4 7.7742l0.10251 7.6366h9.1278l-1.2195 2.1773c-1.554 2.7744-3.2004 4.5278-4.6779 4.9816-1.709 0.52491-7.2982 0.77044-9.5894 0.42125zm9.1393-2.4254c0.69128-0.28883 1.6346-1.0556 2.0963-1.704l0.8394-1.1788h-9.1137c-8.7292 0-9.1137 0.03062-9.1137 0.72577 0 0.56131 0.62208 0.94065 2.7453 1.6741 2.2644 0.78219 3.4937 0.95355 7.0174 0.97821 2.848 0.01993 4.6911-0.14517 5.529-0.49526zm-5.0678-12.791c0-1.7008-0.0483-3.0214-0.10734-2.9346-0.05903 0.08678-1.3658 1.4784-2.904 3.0924l-2.7966 2.9346h5.8079z"  fill="currentColor"/>
        </svg>
      ),
      book: %(
        <svg version="1.1" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
          <path d="m16.24 5.221c-0.07896 0-0.1538 0.0046-0.23044 0.0069v-5.2279h-3.4034c-2.5449 0-4.6153 2.0704-4.6153 4.6153v0.61288c-0.07716-0.0023-0.15226-0.0072-0.23173-0.0072h-7.2692v16.962h7.2692c1.9212 0 2.9289 0.61006 3.6863 1.2849l0.46757 0.46757 0.0108-0.01106 0.07587 0.07587c0.84667-0.84693 1.8173-1.8173 4.2403-1.8173h7.2692v-16.962zm-6.2883-0.60568c0-1.4637 1.1908-2.6545 2.6545-2.6545h1.4426v11.366h-1.4434c-0.98375 0-1.9004 0.31866-2.6537 0.85953zm0 13.337c0.0162-0.86313 0.43491-1.629 1.0676-2.1162v4.4324l-0.2914-0.29114c-0.447-0.447-0.75305-1.2196-0.7762-1.9462zm-7.501 2.27v-13.04h5.3084c0.07999 0 0.15534 0.0041 0.23147 0.0072l-1e-3 10.754c0 0.79806 0.20267 1.6098 0.55862 2.3098-0.25102-0.0198-0.51284-0.03112-0.78906-0.03112zm19.098 0h-5.3084c-1.3796 0-2.432 0.26182-3.2599 0.63578v-5.5695h3.0294v-8.0997c0.07587-0.0031 0.15071-0.0067 0.23044-0.0067h5.3084z" fill="currentColor"/>
        </svg>
      ),
      command: %(
        <svg version="1.1" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
          <path d="m3.7741 23.872c-1.6577-0.40208-3.0787-1.7193-3.5301-3.272-0.12041-0.4142-0.15779-0.88574-0.13285-1.6758 0.031045-0.98388 0.070081-1.1741 0.37129-1.81 0.45306-0.95654 1.4422-1.9475 2.3587-2.3631 0.76933-0.34883 2.0705-0.53999 3.4997-0.51416 0.48674 0.0088 0.94356 0.01145 1.0151 0.0059 0.18906-0.01464 0.18906-4.4828 0-4.4966-0.071581-0.0053-0.57784-0.0016-1.125 0.0078-2.1666 0.037421-3.4921-0.33793-4.5409-1.2859-1.1179-1.0106-1.6072-2.0904-1.6152-3.5653-0.0064595-1.1751 0.25769-2.0553 0.8581-2.8601 1.8109-2.4272 5.0319-2.7349 7.239-0.69147 1.2028 1.1136 1.4979 1.961 1.4995 4.3067 7.87e-4 1.4359 0.0251 1.69 0.16582 1.744 0.21475 0.082413 4.1411 0.082413 4.3559 0 0.1407-0.053992 0.16486-0.30805 0.16582-1.744 7.92e-4 -1.1406 0.04803-1.8353 0.14708-2.1616 0.53744-1.7707 2.0482-3.0976 3.9047-3.4294 1.8483-0.33031 3.8374 0.58378 4.8932 2.2487 0.49969 0.78793 0.65517 1.4841 0.61528 2.7548-0.03247 1.0338-0.06006 1.1568-0.42542 1.8953-0.47248 0.95512-1.3777 1.8471-2.3143 2.2803-0.76054 0.35182-2.0069 0.53527-3.3852 0.49826-0.54996-0.014758-1.0562 8e-3 -1.125 0.05046-0.18355 0.11344-0.17865 4.4338 0.0051 4.448 0.07158 0.0056 0.5284 0.0028 1.0151-0.0059 1.4041-0.02538 2.7319 0.16605 3.4685 0.50003 0.95105 0.43123 1.8568 1.3176 2.3358 2.2858 0.36535 0.73856 0.39296 0.86155 0.42542 1.8953 0.0399 1.2707-0.11559 1.9669-0.61527 2.7548-0.7516 1.1851-1.9616 1.998-3.3564 2.2548-2.2942 0.42232-4.7368-1.1125-5.4356-3.4155-0.10596-0.34926-0.15229-1.0094-0.15307-2.1816-7.87e-4 -1.4359-0.0251-1.69-0.16582-1.744-0.21475-0.08241-4.1411-0.08241-4.3559 0-0.1407 0.05399-0.16485 0.30805-0.16582 1.744-0.0016 2.3203-0.287 3.1597-1.4526 4.2715-1.2321 1.1752-2.8865 1.648-4.4448 1.27zm1.858-2.2652c0.52002-0.1558 1.2763-0.8186 1.5676-1.3739 0.19548-0.37257 0.23104-0.64068 0.26696-2.0129l0.04144-1.583-0.27494-0.069c-0.53369-0.13394-2.8931 0.013617-3.366 0.21053-0.58658 0.24424-1.312 1.0607-1.482 1.668-0.5426 1.938 1.3095 3.7408 3.2469 3.1603zm14.374-0.02609c1.2685-0.45268 1.9992-1.847 1.64-3.1297-0.16102-0.57508-0.8087-1.3364-1.3926-1.6369-0.3546-0.1825-0.66983-0.22962-1.8013-0.26925-0.75432-0.02641-1.4972-0.01649-1.6509 0.02207l-0.27936 0.07012 0.04144 1.583c0.03593 1.3722 0.07147 1.6403 0.26696 2.0129 0.27376 0.52176 1.0394 1.216 1.506 1.3655 0.48087 0.15408 1.21 0.14636 1.6697-0.01771zm-5.7533-7.3996c0.13895-0.08587 0.1421-4.2859 0.0032-4.3717-0.05582-0.03451-1.0643-0.06273-2.2411-0.06273-1.1768 0-2.1853 0.02821-2.2411 0.06273-0.13311 0.08227-0.13559 4.2435-0.0028 4.3765 0.10783 0.10784 4.3066 0.10334 4.4816-0.0048zm-6.8854-6.809c0.22878-0.14495 0.12034-3.066-0.13184-3.5511-0.77223-1.4854-2.4977-1.9863-3.7877-1.0996-1.3448 0.9243-1.5455 2.6367-0.44849 3.8255 0.67833 0.73507 1.2414 0.91087 2.9248 0.91321 0.7158 0.00119 1.3653-0.038598 1.4433-0.088038zm12.873-0.18922c1.9111-1.0127 2.0114-3.508 0.18408-4.5789-0.64322-0.37696-1.7312-0.40681-2.3705-0.064993-0.49292 0.26349-0.99619 0.77583-1.2594 1.282-0.25225 0.48519-0.36037 3.4025-0.13184 3.5573 0.07799 0.052829 0.82117 0.080128 1.6515 0.06066 1.2948-0.03034 1.569-0.066811 1.9262-0.25609z" fill="currentColor"/>
        </svg>
      ),
      flag: %(
        <svg version="1.1" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
          <path d="m3.4102 2v20h2.2871v-10.896h14.838l-3.1113-4.6133 3.168-4.4902z" fill="currentColor"/>
        </svg>
      ),
      leaf: %(
        <svg version="1.1" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
          <path d="m19.612 7.2426c0-2.1553-1.7147-3.0724-2.6356-3.5651-0.19865-0.10624-0.40378-0.21593-0.49424-0.28675-0.21679-0.16972-0.45192-0.52642-0.70088-0.90428-0.69159-1.0494-1.6385-2.4865-3.7817-2.4865-2.1754 0-3.1244 1.5076-3.7523 2.5051-0.23514 0.37355-0.4571 0.72614-0.66353 0.89111-0.08874 0.07104-0.30553 0.18526-0.5152 0.2956-0.93689 0.4936-2.6812 1.4122-2.6812 3.5508 0 1.229 0.63352 2.0573 1.1427 2.7228 0.41933 0.54823 0.67649 0.90558 0.67649 1.3234 0 0.29948-0.11724 0.47309-0.3824 0.83713-0.3485 0.4787-0.8259 1.1342-0.8259 2.289 0 1.9517 1.6358 3.117 3.2179 4.2438 1.52 1.0826 2.956 2.1055 2.956 3.699v1.6423h1.655v-1.6423c0-1.5935 1.4359-2.6164 2.9562-3.699 1.5818-1.1267 3.2177-2.292 3.2177-4.2438 0-1.1547-0.47741-1.8103-0.8259-2.289-0.26515-0.36404-0.38219-0.53765-0.38219-0.83713 0-0.41782 0.25694-0.77516 0.67627-1.3234 0.50915-0.66547 1.1427-1.4938 1.1427-2.7228m-1.6553 0c0 0.6685-0.3716 1.1545-0.80194 1.7172-0.47676 0.62315-1.017 1.3295-1.017 2.329 0 0.85094 0.38779 1.3834 0.69937 1.8114 0.29538 0.40572 0.50872 0.69872 0.50872 1.3147 0 1.0986-1.169 1.9312-2.5229 2.8955-0.67476 0.48086-1.3828 0.9887-1.9957 1.5754v-2.2518l2.5211-2.5211-1.1705-1.1705-1.3506 1.3508v-3.1764l3.1786-3.1783-1.1705-1.1705-2.0081 2.0081v-4.1815h-1.655v4.1813l-2.0081-2.0078-1.1703 1.1705 3.1783 3.1782v3.1766l-1.3506-1.3508-1.1705 1.1705 2.5211 2.5211v2.2517c-0.61301-0.58644-1.3208-1.0943-1.9957-1.5751-1.3538-0.96409-2.5229-1.7969-2.5229-2.8955 0-0.61603 0.21334-0.90904 0.50872-1.3147 0.31158-0.42796 0.69937-0.96042 0.69937-1.8114 0-0.9995-0.54024-1.7058-1.0168-2.329-0.43055-0.56269-0.80215-1.0487-0.80215-1.7172 0-1.0556 0.77883-1.5499 1.7974-2.0862 0.30359-0.16 0.56593-0.29797 0.77775-0.46747 0.42428-0.33943 0.71858-0.80712 1.0302-1.302 0.67821-1.0775 1.1751-1.7317 2.3516-1.7317 1.1675 0 1.6853 0.65813 2.3995 1.742 0.32561 0.49403 0.63308 0.96063 1.0632 1.2971 0.2034 0.15935 0.4489 0.29063 0.73327 0.44264 0.99777 0.53376 1.7611 1.0278 1.7611 2.1056" fill="currentColor"/>
        </svg>
      ),
      "sport-football": %(
        <svg version="1.1" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
          <path d="m11.571 0.71461c-1.1316-0.01161-2.072 0.87136-2.142 2.0029-0.0723 1.1801 0.81906 2.1795 1.9992 2.2518 1.1801 0.07225 2.1796-0.83086 2.2518-1.9989 0.0723-1.1801-0.83086-2.1795-1.999-2.2518-0.0369-0.0023-0.0736-0.0036-0.11007-0.003999zm-0.74488 4.6884c-0.27697-0.01204-0.54209 0.03613-0.79497 0.12042-0.0361 0.01204-0.0843 0.03594-0.12043 0.04798l-1.3848 0.78274-1.5655 0.87916-0.33704 0.19263c-0.7707 0.43352-1.0838 1.0237-1.4571 1.7221l-1.6257 2.9863 1.7339 0.08444 1.6981-2.7095 1.3968-0.86717 0.12042-0.07221-0.0242 0.16864-0.5419 3.8775h0.0242v0.01223l-0.0242-0.01223-2.6131 4.0583-5.3106 0.25284 0.96338 1.7581 5.5394-0.0842c0.30105 0 0.44561-0.15655 0.5299-0.24084l2.9743-3.4562 2.6253 2.8661 0.99937 5.4552 2.0352 0.06021-0.84296-6.2017c-0.06021-0.2288-0.1566-0.45769-0.28906-0.63832l-2.3842-3.2996-0.0242 0.01199v-0.02399h0.0242l0.036-0.30105 0.0482-0.30105 0.32504-2.1194 0.0964-0.65032 0.73453 0.79473c0.5419 0.57802 1.3609 0.80691 2.1316 0.57811l3.5402-0.81895-0.96338-1.3606-3.2272 0.57788-2.0232-3.0587c-0.0361-0.06021-0.0842-0.12042-0.13241-0.18063-0.44557-0.56598-1.1439-0.90297-1.8905-0.89092zm10.248 9.8143a2.9263 2.9262 0 0 0-2.9264 2.9261 2.9263 2.9262 0 0 0 2.9264 2.9263 2.9263 2.9262 0 0 0 2.9261-2.9263 2.9263 2.9262 0 0 0-2.9261-2.9261z" fill="currentColor"/>
        </svg>
      ),
      "sport-hockey": %(
        <svg version="1.1" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
          <path d="m2.4912e-8 19.823v-2.2171h7.7598v4.4342h-7.7598zm12.009 1.6923c-0.6097-0.27269-1.3242-0.85848-1.5879-1.3017-0.6526-1.0973-5.3178-16.255-5.1541-16.746 0.16201-0.48602 4.8056-1.7979 5.1297-1.4492 0.12939 0.13924 0.94332 2.5811 1.8087 5.4263 0.86542 2.8452 1.7215 5.4642 1.9024 5.8198 0.27981 0.55004 0.87451 0.64665 3.9809 0.64665 4.2654 0 4.6691 0.11271 5.3888 1.5045 1.1399 2.2044 0.31756 5.5674-1.5335 6.2712-1.4134 0.53738-8.6289 0.41312-9.9351-0.1711zm9.7182-2.1358c0.54474-0.54474 0.57413-1.9475 0.0609-2.9065-0.34482-0.64431-0.80982-0.71473-4.7192-0.71473h-4.3367l-0.97692-3.2332c-0.5373-1.7783-1.3323-4.414-1.7666-5.8573-0.73162-2.4311-0.85616-2.6113-1.6941-2.4511-0.49746 0.095095-0.90448 0.30863-0.90448 0.47451 0 0.71529 4.1831 13.547 4.6619 14.3 0.49893 0.78523 0.76996 0.8314 4.88 0.8314 2.892 0 4.5005-0.14874 4.7951-0.44342z" fill="currentColor"/>
        </svg>
      ),
      "sport-running": %(
        <svg version="1.1" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
          <path d="m14.04 0.71461c-1.1316-0.01161-2.072 0.87136-2.142 2.0029-0.0723 1.1801 0.81906 2.1795 1.9992 2.2518 1.1801 0.07225 2.1796-0.83086 2.2518-1.9989 0.0723-1.1801-0.83086-2.1795-1.999-2.2518-0.0369-0.0023-0.0736-0.0036-0.11007-0.003999zm-0.74488 4.6884c-0.27697-0.01204-0.54209 0.03613-0.79497 0.12042-0.0361 0.01204-0.0843 0.03594-0.12043 0.04798l-1.3848 0.78274-1.5655 0.87916-0.33704 0.19263c-0.7707 0.43352-1.0838 1.0237-1.4571 1.7221l-1.6257 2.9863 1.7339 0.08444 1.6981-2.7095 1.3968-0.86717 0.12042-0.07221-0.0242 0.16864-0.5419 3.8775h0.0242v0.01223l-0.0242-0.01223-2.6131 4.0583-5.3106 0.25284 0.96338 1.7581 5.5394-0.0842c0.30105 0 0.44561-0.15655 0.5299-0.24084l2.9743-3.4562 2.6253 2.8661 0.99937 5.4552 2.0352 0.06021-0.84296-6.2017c-0.06021-0.2288-0.1566-0.45769-0.28906-0.63832l-2.3842-3.2996-0.0242 0.01199v-0.02399h0.0242l0.036-0.30105 0.0482-0.30105 0.32504-2.1194 0.0964-0.65032 0.73453 0.79473c0.5419 0.57802 1.3609 0.80691 2.1316 0.57811l3.5402-0.81895-0.96338-1.3606-3.2272 0.57788-2.0232-3.0587c-0.0361-0.06021-0.0842-0.12042-0.13241-0.18063-0.44557-0.56598-1.1439-0.90297-1.8905-0.89092z" fill="currentColor"/>
        </svg>
      ),
      "transit-metro": %(
        <svg version="1.1" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
          <path d="m12 2.102c-4.6078 0-6.8286 0.13281-7.7237 0.43115-1.5912 0.5967-2.453 1.3262-3.3149 3.0168-0.66299 1.1934-0.72959 1.9555-0.82904 7.8561l-0.13242 6.5639h2.0553v-6.2985c0-6.862 0.16576-7.5914 1.8564-8.9174 0.82874-0.663 1.2926-0.696 8.0883-0.696 6.7956 0 7.2602 0.033 8.0889 0.696 1.6906 1.326 1.8564 2.0554 1.8564 8.9174v6.2985h2.0547l-0.13242-6.5639c-0.09945-5.9007-0.16542-6.6628-0.82841-7.8561-1.6243-3.0829-2.785-3.448-11.039-3.448zm0.04393 4.3724c-7.4675 0-7.7132 0.21884-7.7098 6.8759 2e-3 3.9667 0.36081 5.4546 1.466 6.0732 0.25992 0.14546 0.46002 0.73842 0.46002 1.3656 0 1.0176 0.07915 1.1089 0.96397 1.1089 0.85686 0 0.96397-0.10711 0.96397-0.96398v-0.96398h7.7117v0.96398c0 0.85687 0.10711 0.96398 0.96397 0.96398 0.88482 0 0.96397-0.09131 0.96397-1.1089 0-0.62722 0.19946-1.2202 0.45939-1.3656 1.1052-0.61852 1.4641-2.1064 1.466-6.0732 0.0034-6.657-0.24174-6.8759-7.7092-6.8759zm-5.6231 2.0886h11.246v9.3184l-5.5503 0.08786c-4.372 0.06928-5.5843-0.0025-5.7129-0.33764-0.0898-0.23402-0.12298-2.3702-0.07343-4.7471zm2.2882 5.4236a1.548 1.548 0 0 0-1.5482 1.5483 1.548 1.548 0 0 0 1.5482 1.5483 1.548 1.548 0 0 0 1.5476-1.5483 1.548 1.548 0 0 0-1.5476-1.5483zm6.776 6.11e-4a1.548 1.548 0 0 0-1.5482 1.5476 1.548 1.548 0 0 0 1.5482 1.5483 1.548 1.548 0 0 0 1.5476-1.5483 1.548 1.548 0 0 0-1.5476-1.5476z" fill="currentColor"/>
        </svg>
      ),
      "transit-train": %(
        <svg version="1.1" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
          <path d="m12 2.4242e-8c-8.8801 0-9.3167 0.4694-9.3167 10.019 0 6.0657 0.25276 7.4725 1.5848 8.8046 0.73422 0.73422 0.72518 0.86997-0.18457 2.7425-0.52644 1.0836-0.95662 2.0647-0.95662 2.1801 0 0.54255 2.1539 0.13067 2.3786-0.45492 0.21024-0.54788 1.358-0.66548 6.4945-0.66548 5.1365 0 6.2834 0.1176 6.4936 0.66548 0.22471 0.58558 2.3794 0.99747 2.3794 0.45492 0-0.11548-0.43105-1.0966-0.95749-2.1801-0.90974-1.8725-0.91879-2.0083-0.18457-2.7425 1.3321-1.3321 1.5857-2.7389 1.5857-8.8046 0-9.55-0.43653-10.019-9.3167-10.019zm-6.4329 2.8837h12.866v14.197l-6.3316 0.12304c-4.9268 0.09583-6.3809-0.0073-6.556-0.46358-0.12374-0.32246-0.17006-3.5721-0.10225-7.2215zm3.0458 8.7535a2.0319 2.0319 0 0 0-2.032 2.032 2.0319 2.0319 0 0 0 2.032 2.032 2.0319 2.0319 0 0 0 2.032-2.032 2.0319 2.0319 0 0 0-2.032-2.032zm6.6799 0a2.0319 2.0319 0 0 0-2.032 2.032 2.0319 2.0319 0 0 0 2.032 2.032 2.0319 2.0319 0 0 0 2.032-2.032 2.0319 2.0319 0 0 0-2.032-2.032zm-3.2927 8.5117c2.5408 0 5.0815 0.19762 5.2129 0.59182 0.14113 0.42339-1.0919 0.55456-5.2129 0.55456s-5.354-0.13117-5.2129-0.55456c0.1314-0.39421 2.6722-0.59182 5.2129-0.59182z" fill="currentColor"/>
        </svg>
      ),
      "transit-tram": %(
        <svg version="1.1" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
          <path d="m5.2 23.78c0-0.12092 0.26252-0.72753 0.58339-1.348 0.5275-1.0201 0.50834-1.2753-0.2-2.6647-0.66594-1.3062-0.78339-2.3654-0.78339-7.0648 0-7.696 0.71485-9.1026 4.626-9.1026 0.95463 0 1.374-0.18312 1.374-0.6 0-0.46667-0.53333-0.6-2.4-0.6h-2.4v-2.4h12v2.4h-2.4c-1.8667 0-2.4 0.13333-2.4 0.6 0 0.41688 0.41933 0.6 1.374 0.6 3.9112 0 4.626 1.4066 4.626 9.1026 0 4.6995-0.11745 5.7586-0.78339 7.0648-0.70834 1.3894-0.7275 1.6446-0.2 2.6647 0.76768 1.4845 0.74811 1.5679-0.36808 1.5679-0.68007 0-1.0933-0.3423-1.4485-1.2l-0.49706-1.2h-7.8059l-0.49706 1.2c-0.35527 0.8577-0.76846 1.2-1.4485 1.2-0.52331 0-0.95147-0.09894-0.95147-0.21986zm11.4-11.18v-6.4h-9.2l-0.11116 5.9824c-0.06114 3.2903-0.01952 6.2213 0.0925 6.5132 0.15623 0.40713 1.2535 0.50439 4.7112 0.41757l4.5075-0.11317zm-5.7841 5.2192c-0.62184-0.74927-0.40464-1.8146 0.48405-2.3743 1.386-0.87281 2.9466 1.094 1.8841 2.3743-0.61784 0.74446-1.7503 0.74446-2.3681 0z" fill="currentColor"/>
        </svg>
      )
    }
    # rubocop:enable Layout/LineLength
    # Extra icons not available in the original set
    extra_icons = {
      bicycle: nil,
      binoculars: "binoculars",
      boat: nil,
      "calendar-clock": "calendar-clock",
      command: nil,
      company: "company",
      "face-smile": "face-smile",
      "heart-line": "heart",
      "home-smoke": "home-smoke",
      "info-line": "info-circle",
      leaf: nil,
      "sport-football": nil,
      "sport-hockey": nil,
      "sport-running": nil,
      "star-line": "star",
      "transit-metro": nil,
      "transit-train": nil,
      "transit-tram": nil,
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
