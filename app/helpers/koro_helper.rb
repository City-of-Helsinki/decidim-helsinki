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
    css_class = "koro koro-#{type}"
    css_class += " flip-horizontal" if options.delete(:flip)

    extra_class = options.delete(:class)
    css_class += " #{extra_class}" if extra_class

    content_tag :div, { class: css_class }.merge(options), "aria-hidden": true do
      koro_svg(type)
    end
  end

  private

  def koro_svg(type)
    pattern_name = "koro_#{type}"
    pattern_id = "#{pattern_name}-#{rand(36**8).to_s(36)}"
    height = koro_height(type)
    whitespace = 4 # How many pixels whitespace in the SVG rectangle

    # The SVG element is less in height than the elements inside in order to
    # avoid extra element lines when the screen is scaled/zoomed.
    content_tag :svg, xmlns: "http://www.w3.org/2000/svg", width: "100%", height: height do
      defs = content_tag :defs do
        content_tag :pattern, id: pattern_id, x: 0, y: 0, width: 106, height: height + whitespace, patternUnits: "userSpaceOnUse" do
          koro_svg_pattern(type).html_safe
        end
      end

      defs + %(<rect fill="url(##{pattern_id})" width="100%" height="#{height}" />).html_safe
    end
  end

  def koro_height(type)
    case type
    when "beat"
      76
    when "pulse"
      40
    when "storm"
      41
    when "wave"
      60
    else # basic
      20
    end
  end

  def koro_svg_pattern(type)
    case type
    when "beat"
      # rubocop:disable Layout/LineLength
      %(
        <path
          d="M106,76h-106v-76c14.84 0 18.55 12.19 18.55 12.19l14.84 44.52c3.18 7.95 10.07 13.25 19.08 13.25 14.84 0 19.08-13.25 19.08-13.25s14.84-42.93 14.84-43.46c3.71-7.95 10.6-13.25 19.61-13.25z"
        />
      )
      # rubocop:enable Layout/LineLength
    when "pulse"
      %(<path d="M0,40h106v-40c-27.03 0-27.03 34.217-53 34.217s-27.03-34.217-53-34.217z" />)
    when "storm"
      %(<path d="M106,41V0C 93.81,29.15 59.89,42.93 30.21,30.21 16.43,24.91 6.36,13.78 0,0v41z" />)
    when "wave"
      %(<polygon points="106 0 51.94 53.53 0 0 0 60 106 60" />)
    else # basic
      %(<path d="M0,20h106v-20c-25.97 0-26.5 13.78-52.47 13.78s-27.03-13.78-53.53-13.78z" />)
    end
  end
end
