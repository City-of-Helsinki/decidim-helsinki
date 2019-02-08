# frozen_string_literal: true

# This controller has been overridden because of the following bug:
# https://github.com/decidim/decidim/issues/4669
#
# FIXME: Remove this override after the bug is fixed.
module Decidim
  class StaticMapController < Decidim::ApplicationController
    skip_before_action :store_current_location

    def show
      send_data StaticMapGenerator.new(resource).data, type: "image/jpeg", disposition: "inline"
    end

    private

    def resource
      @resource ||= GlobalID::Locator.locate_signed params[:sgid]
    end
  end
end
