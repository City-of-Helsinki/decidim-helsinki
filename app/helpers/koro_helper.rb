# frozen_string_literal: true

# The "koro" images (aka. wave motifs) are used in the Helsinki design language
# and they are part of the visual identity of the City of Helsinki. This module
# provides helper methods for creating these koro images in the layout.
#
# This is ported to Rails from the HDS (Helsinki Design System) repository's
# React component. The SVG shapes are modified for this project in order to
# avoid the excess overflow lines when zooming the screen or viewing in scaled
# mode. These lines appear when the repeat pattern starts over when scaling the
# SVG rectangle up or down. The modified SVGs do not cause this as they leave
# some extra whitespace around the repeated pattern.
#
# See: https://github.com/City-of-Helsinki/helsinki-design-system
module KoroHelper
  def koro(type = "basic", options = {})
    # Old name for "wave" was "vibration".
    type = "wave" if type == "vibration"
    return unless %w(basic beat pulse storm wave).include?(type)

    css_class = "koro koro-#{type}"
    css_class += " flip-vertical" if options.delete(:flip)

    extra_class = options.delete(:class)
    css_class += " #{extra_class}" if extra_class

    content_tag :div, { class: css_class }.merge(options), "aria-hidden": true do
      koro_svg(type)
    end
  end

  private

  # Instead of the HDS, the koro SVGs and styling are adapted from the Hel.fi
  # site's theme because they are different than the default koro patterns
  # provided by HDS. See:
  # https://github.com/City-of-Helsinki/drupal-hdbt/tree/main/templates/misc/koros
  #
  # The default patterns provided by HDS are narrower than those at Hel.fi which
  # is why we use those variants instead as they match the desired layout
  # better.
  def koro_svg(type)
    pattern_name = "koro_#{type}"
    pattern_id = "#{pattern_name}-#{rand(36**8).to_s(36)}"
    height = koro_height(type)
    pattern_width = 67
    pattern_height = 50
    pattern_height = 49 if type == "basic"

    # The SVG element is less in height than the elements inside in order to
    # avoid extra element lines when the screen is scaled/zoomed.
    content_tag :svg, xmlns: "http://www.w3.org/2000/svg", width: "100%", height: height, aria: { hidden: true } do
      defs = content_tag :defs do
        content_tag :pattern, id: pattern_id, x: 0, y: height - pattern_height, width: pattern_width, height: pattern_height, patternUnits: "userSpaceOnUse" do
          koro_svg_pattern(type).html_safe
        end
      end

      # defs + %(<rect fill="url(##{pattern_id})" width="100%" height="#{height}" />).html_safe
      defs + %(<rect fill="url(##{pattern_id})" width="100%" height="#{height}" />).html_safe
    end
  end

  def koro_height(type)
    case type
    when "beat"
      49
    when "pulse"
      37
    when "storm"
      38
    when "wave"
      42
    else # basic
      30
    end
  end

  # Note that the "calm" type is not implemented as we do not need to add koro
  # in that case.
  def koro_svg_pattern(type)
    case type
    when "beat"
      # rubocop:disable Layout/LineLength
      %(
        <path
          d="M 67 52 v -5 h -0.14 c -8.59 0 -11.79 -8 -11.79 -8 S 45.79 10.82 45.7 10.61 A 13 13 0 0 0 33.53 2 C 24.28 2 21.35 10.61 21.35 10.61 L 12 38.71 A 12.94 12.94 0 0 1 0 47.06 V 52 Z"
        />
      )
      # rubocop:enable Layout/LineLength
    when "pulse"
      %(<path d="M 67 63.5 V 35.86 C 50.4 35.74 50.35 13.5 33.65 13.5 S 16.91 35.87 0.17 35.87 H 0 V 63.5 Z" />)
    when "storm" # old name: "wave" (as in the Hel.fi theme)
      %(<path class="cls-1" d="M 67 63.5 V 36.89 h 0 c -15 0 -27.91 -9.64 -33.46 -23.34 C 27.93 27.23 15 36.81 0 36.79 V 63.5 Z" />)
    when "wave" # old name: "vibration" (as in the Hel.fi theme)
      %(<polygon points="67 50 67 42.36 33.5 8.5 0 42.36 0 42.36 0 50 67 50" />)
    else # basic
      %(<path d="M 67 70 V 30.32 h 0 C 50.25 30.32 50.25 20 33.5 20 S 16.76 30.32 0 30.32 H 0 V 70 Z" />)
    end
  end
end
