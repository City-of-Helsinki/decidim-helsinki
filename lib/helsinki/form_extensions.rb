# frozen_string_literal: true

module Helsinki
  module FormExtensions
    module CollectionCheckBoxes
      extend ActiveSupport::Concern

      included do
        private

        alias_method :rails_render_component, :render_component unless method_defined?(:rails_render_component)

        def render_component(builder)
          content_tag(:div, rails_render_component(builder), class: "input-checkbox")
        end
      end
    end

    module CollectionRadioButtons
      extend ActiveSupport::Concern

      included do
        private

        alias_method :rails_render_component, :render_component unless method_defined?(:rails_render_component)

        def render_component(builder)
          content_tag(:div, rails_render_component(builder), class: "input-radio")
        end
      end
    end

    # module RadioButton
    #   extend ActiveSupport::Concern

    #   included do
    #     alias_method :rails_render, :render unless method_defined?(:rails_render)

    #     # ActionView::Helpers::Tags::RadioButton#render
    #     def render
    #       content_tag("div", rails_render, class: "input-radio")
    #     end
    #   end
    # end

    # module CheckBox
    #   extend ActiveSupport::Concern

    #   included do
    #     alias_method :rails_render, :render unless method_defined?(:rails_render)

    #     # ActionView::Helpers::Tags::CheckBox#render
    #     def render
    #       content_tag("div", rails_render, class: "input-checkbox")
    #     end
    #   end
    # end
  end
end
