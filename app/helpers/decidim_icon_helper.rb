# frozen_string_literal: true

module DecidimIconHelper
  # This is the original `icon` method from Decidim::LayoutHelper because
  # we have overridden that method for the participant side.
  def decidim_icon(name, options = {})
    options = options.with_indifferent_access
    html_properties = {}

    html_properties["width"] = options[:width]
    html_properties["height"] = options[:height]
    html_properties["aria-label"] = options[:aria_label] || options[:"aria-label"]
    html_properties["role"] = options[:role] || "img"
    html_properties["aria-hidden"] = options[:aria_hidden] || options[:"aria-hidden"]

    html_properties["class"] = (["icon--#{name}"] + _icon_classes(options)).join(" ")

    title = options["title"] || html_properties["aria-label"]
    if title.blank? && html_properties["role"] == "img"
      # This will make the accessibility audit tools happy as with the "img"
      # role, the alternative text (aria-label) and title are required for the
      # element. This will also force the SVG to be hidden because otherwise
      # the screen reader would announce the icon name which can be in
      # different language (English) than the page language which is not
      # allowed.
      title = name
      html_properties["aria-label"] = title
      html_properties["aria-hidden"] = true
    end

    href = Decidim.cors_enabled ? "" : asset_pack_path("media/images/icons.svg")

    content_tag :svg, html_properties do
      inner = content_tag :title, title
      inner += content_tag :use, nil, "href" => "#{href}#icon-#{name}"

      inner
    end
  end
end
