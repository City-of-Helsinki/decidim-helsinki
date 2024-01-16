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
          <path d="m13.39 3.468.931.383c.885.433 1.572 1.1 1.893 1.986l1.927 5.238a5 5 0 1 1-1.844.718L16.004 11h-.612c-2.028 1.408-3.542 4.705-5.461 5.833a5 5 0 1 1-3.5-5.625l.877-1.518L6.694 8H5V6l.668.017c1.712.06 2.858.23 3.44.51.653.316.95.806.892 1.473H7.758l.365 1h7.143l-.917-2.485c-.162-.444-.497-.76-.95-.994l-.727-.315.719-1.739ZM5 12.5A3.5 3.5 0 1 0 8.355 17h-2.9c-.525 0-1.02 0-1.34-.279a.924.924 0 0 1-.248-1.056l.056-.113 1.727-2.99A3.398 3.398 0 0 0 5 12.5Zm14 0c-.111 0-.222.005-.33.015l1.082 2.964c.205.564.033 1.19-.455 1.357-.574.196-1.162-.054-1.399-.7l-1.063-2.883A3.5 3.5 0 1 0 19 12.5Zm-11.565.986-.863 1.515L8.355 15a3.5 3.5 0 0 0-.92-1.513ZM12.412 11l-3.551.001-.664 1.156a4.994 4.994 0 0 1 1.499 2.121c1.155-1.182 1.773-2.251 2.716-3.278Z" fill="currentColor"/>
        </svg>
      ),
      boat: %(
        <svg version="1.1" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
          <path d="M14.543 2.18a1 1 0 0 1 .457.838v11.993l8.142-.014-2 3.695a6.003 6.003 0 0 1-4.784 3.12c-3.982.326-6.838.233-8.627-.31-1.741-.528-3.24-1.058-4.5-1.593a2.001 2.001 0 0 1-1.215-1.825l-.024-3.047 12.006-.024V13H5.692a1 1 0 0 1-.997-1.002c0-.288.125-.561.344-.749l.742-.653c2.772-2.462 4.709-4.41 5.808-5.845l.139-.184c.403-.546.88-1.242 1.433-2.089a.998.998 0 0 1 1.382-.297Zm5.238 14.822-15.774.031.009 1.036c1.185.504 2.618 1.01 4.295 1.52 1.487.45 4.134.537 7.883.23a4.002 4.002 0 0 0 3.189-2.08l.398-.737ZM13 10.932V5.76l-.205.257C11.944 7.052 10.345 8.69 8 10.932h5Z" fill="currentColor"/>
        </svg>
      ),
      book: %(
        <svg version="1.1" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
          <path d="m16.24 5.221c-0.07896 0-0.1538 0.0046-0.23044 0.0069v-5.2279h-3.4034c-2.5449 0-4.6153 2.0704-4.6153 4.6153v0.61288c-0.07716-0.0023-0.15226-0.0072-0.23173-0.0072h-7.2692v16.962h7.2692c1.9212 0 2.9289 0.61006 3.6863 1.2849l0.46757 0.46757 0.0108-0.01106 0.07587 0.07587c0.84667-0.84693 1.8173-1.8173 4.2403-1.8173h7.2692v-16.962zm-6.2883-0.60568c0-1.4637 1.1908-2.6545 2.6545-2.6545h1.4426v11.366h-1.4434c-0.98375 0-1.9004 0.31866-2.6537 0.85953zm0 13.337c0.0162-0.86313 0.43491-1.629 1.0676-2.1162v4.4324l-0.2914-0.29114c-0.447-0.447-0.75305-1.2196-0.7762-1.9462zm-7.501 2.27v-13.04h5.3084c0.07999 0 0.15534 0.0041 0.23147 0.0072l-1e-3 10.754c0 0.79806 0.20267 1.6098 0.55862 2.3098-0.25102-0.0198-0.51284-0.03112-0.78906-0.03112zm19.098 0h-5.3084c-1.3796 0-2.432 0.26182-3.2599 0.63578v-5.5695h3.0294v-8.0997c0.07587-0.0031 0.15071-0.0067 0.23044-0.0067h5.3084z" fill="currentColor"/>
        </svg>
      ),
      "circle-hollow": %(
        <svg role="img" version="1.1" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
          <path d="m12 2c5.5228 0 10 4.4772 10 10 0 5.5228-4.4772 10-10 10-5.5228 0-10-4.4772-10-10 0-5.5228 4.4772-10 10-10zm0 2c-4.4183 0-8 3.5817-8 8s3.5817 8 8 8 8-3.5817 8-8-3.5817-8-8-8z" fill="currentColor"/>
        </svg>
      ),
      command: %(
        <svg version="1.1" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
          <path d="M2 6a4 4 0 1 1 8 0v2h4V6a4 4 0 1 1 4 4h-2v4h2a4 4 0 1 1-4 4v-2h-4v2a4 4 0 1 1-4-4h2v-4H6a4 4 0 0 1-4-4Zm6 10H6a2 2 0 1 0 2 2v-2Zm10 0h-2v2a2 2 0 1 0 2-2Zm-4-6h-4v4h4v-4Zm4-6a2 2 0 0 0-2 2v2h2a2 2 0 1 0 0-4ZM6 4a2 2 0 0 0-.15 3.995L6 8h2V6a2 2 0 0 0-2-2Z" fill="currentColor"/>
        </svg>
      ),
      flag: %(
        <svg version="1.1" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
          <path d="m3.4102 2v20h2.2871v-10.896h14.838l-3.1113-4.6133 3.168-4.4902z" fill="currentColor"/>
        </svg>
      ),
      leaf: %(
        <svg version="1.1" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
          <path d="M12.5 1c2.083 0 2.983 1.539 3.583 2.571.173.35.397.67.663.952.174.11.355.207.542.291l.215.099C18.48 5.372 20 6.253 20 8.243c0 1.243-.654 2.074-1.18 2.76l-.238.297c-.289.373-.457.663-.457.989.024.303.156.587.37.797.49.629.751 1.414.738 2.22 0 1.709-1.243 2.816-2.615 3.864l-.959.725c-1.205.93-2.223 1.87-2.325 3.235v.873h-1.667l.001-1.187c-.233-1.246-1.28-2.155-2.433-3.045l-.803-.616c-1.346-1.04-2.624-2.157-2.624-3.866a3.522 3.522 0 0 1 .738-2.22c.2-.217.316-.5.329-.798 0-.39-.28-.741-.696-1.285l-.215-.277C5.491 10.089 5 9.32 5 8.243 5 6.113 6.792 5.26 7.775 4.8c.194-.081.38-.18.558-.295a3.66 3.66 0 0 0 .613-.935l.139-.243C9.665 2.322 10.577 1 12.5 1Zm0 2c-.711 0-1.088.31-1.695 1.35l-.099.172-.067.14a5.66 5.66 0 0 1-.633.964l-.188.22-.177.196-.221.143a5.303 5.303 0 0 1-.8.429C7.403 7.182 7 7.561 7 8.243c0 .38.138.698.513 1.198l.254.329.367.487c.412.562.54.828.667 1.369.049.21.074.426.072.732a3.26 3.26 0 0 1-.707 1.892l-.048.054-.078.112a1.54 1.54 0 0 0-.227.711l-.005.162c0 .624.396 1.14 1.798 2.243l.646.498c.54.413 1.01.795 1.415 1.163v-1.59l-2.417-2.49 1.133-1.17 1.283 1.32v-3.176l-2.95-3.038 1.138-1.17 1.812 1.868V6.143h1.667v3.604l1.813-1.868 1.137 1.17-2.951 3.039v3.175l1.285-1.32 1.133 1.17-2.419 2.491v1.63c.285-.26.6-.525.947-.798l1.166-.889c1.389-1.076 1.79-1.606 1.79-2.274.005-.3-.078-.593-.233-.84l-.051-.072-.136-.162a3.256 3.256 0 0 1-.659-1.54l-.024-.212-.006-.158c0-1 .317-1.542 1.108-2.502l.245-.323c.385-.522.522-.84.522-1.221 0-.705-.41-1.099-1.538-1.607a6.515 6.515 0 0 1-.781-.42l-.214-.135-.173-.182a5.88 5.88 0 0 1-.867-1.18l-.087-.166-.102-.174c-.606-1.01-.972-1.34-1.614-1.376L12.5 3Z" fill="currentColor"/>
        </svg>
      ),
      "sport-football": %(
        <svg version="1.1" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
          <path d="m9.136 5.69 7.704 2.674a1 1 0 0 0 .74-.034l2.351-1.067.826 1.822-2.35 1.066a3 3 0 0 1-2.223.102l-1.924-.668-1.767 4.162 1.95 1.746c.264.237.415.576.415.931v5.619h-2.5V16.98l-2.714-2.429-1.202 1.83a1.15 1.15 0 0 1-.961.518H1.88v-2.3h.974l3.832-.01.995-2.303L9.525 7.94 8.48 7.58a1 1 0 0 0-1.024.226L5.66 9.545 4.268 8.108l1.797-1.74a3 3 0 0 1 3.07-.679ZM19.75 17a2.25 2.25 0 1 1 0 4.5 2.25 2.25 0 0 1 0-4.5ZM13.996 2.035a2 2 0 1 1 0 4 2 2 0 0 1 0-4Z" fill="currentColor"/>
        </svg>
      ),
      "sport-hockey": %(
        <svg version="1.1" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
          <path d="m5.277 3.9 5.196-1.393 3.432 10.904H20c1.63 0 2.784 1.65 2.859 3.593l.004.202C22.863 19.236 21.687 21 20 21h-6.99c-1.593 0-2.736-1.144-3.32-2.772L5.277 3.899ZM8 17v4H1v-4h7ZM9.188 4.91l-1.461.404 3.858 12.278c.317.88.844 1.408 1.425 1.408H20c.37 0 .863-.738.863-1.794s-.492-1.794-.863-1.794h-7.619L9.188 4.91Z" fill="currentColor"/>
        </svg>
      ),
      "sport-running": %(
        <svg version="1.1" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
          <path fill-rule="evenodd" d="m9.136 5.69 7.704 2.674a1 1 0 0 0 .74-.034l2.351-1.067.826 1.822-2.35 1.066a3 3 0 0 1-2.223.102l-1.924-.668-1.767 4.162 1.95 1.746c.264.237.415.576.415.931v5.619h-2.5V16.98l-2.714-2.429-1.202 1.83a1.15 1.15 0 0 1-.961.518H1.88v-2.3h.974l3.832-.01.995-2.303L9.525 7.94 8.48 7.58a1 1 0 0 0-1.024.226L5.66 9.545 4.268 8.108l1.797-1.74a3 3 0 0 1 3.07-.679ZM19.75 17a2.25 2.25 0 1 1 0 4.5 2.25 2.25 0 0 1 0-4.5ZM13.996 2.035a2 2 0 1 1 0 4 2 2 0 0 1 0-4Z" fill="currentColor"/>
        </svg>
      ),
      "transit-metro": %(
        <svg version="1.1" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
          <path d="M17 5a3 3 0 0 1 3 3v8a3.001 3.001 0 0 1-2 2.829V21h-2v-2H8v2H6v-2.17A3.001 3.001 0 0 1 4 16V8a3 3 0 0 1 3-3h10Zm1-4c3.344 0 6 3.01 6 6.667V19h-2V7.667C22 5.063 20.18 3 18 3H6C3.82 3 2 5.063 2 7.667V19H0V7.667C0 4.01 2.656 1 6 1h12Zm-1 6H7a1 1 0 0 0-1 1v8a1 1 0 0 0 1 1h10a1 1 0 0 0 1-1V8a1 1 0 0 0-1-1Zm-8.5 6a1.5 1.5 0 1 1 0 3 1.5 1.5 0 0 1 0-3Zm7 0a1.5 1.5 0 1 1 0 3 1.5 1.5 0 0 1 0-3Z" fill="currentColor"/>
        </svg>
      ),
      "transit-train": %(
        <svg version="1.1" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
          <path d="M16 4a3 3 0 0 1 3 3v9a3 3 0 0 1-1.657 2.684L19 22h-2l-.5-1h-9L7 22H5l1.658-3.316A3 3 0 0 1 5 16V7a3 3 0 0 1 3-3h8Zm-.5 15h-7L8 20h8l-.5-1ZM16 6H8a1 1 0 0 0-1 1v9a1 1 0 0 0 1 1h8a1 1 0 0 0 1-1V7a1 1 0 0 0-1-1Zm-6.5 7a1.5 1.5 0 1 1 0 3 1.5 1.5 0 0 1 0-3Zm5 0a1.5 1.5 0 1 1 0 3 1.5 1.5 0 0 1 0-3Z" fill="currentColor"/>
        </svg>
      ),
      "transit-tram": %(
        <svg version="1.1" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
          <path d="M17 2v2h-4v1h2.429C16.849 5 18 6.343 18 8v9c0 1.08-.489 2.026-1.222 2.554L18 22h-2l-1.001-2H9l-1 2H6l1.223-2.445C6.49 19.027 6 18.08 6 17V8c0-1.657 1.151-3 2.571-3H11V4H7V2h10Zm-1.8 5H8.8c-.442 0-.8.448-.8 1v9c0 .552.358 1 .8 1h6.4c.442 0 .8-.448.8-1V8c0-.552-.358-1-.8-1ZM12 14.5a1.5 1.5 0 1 1 0 3 1.5 1.5 0 0 1 0-3Z" fill="currentColor"/>
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
      "circle-hollow": nil,
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
