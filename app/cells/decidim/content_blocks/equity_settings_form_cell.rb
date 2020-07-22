# frozen_string_literal: true

module Decidim
    module ContentBlocks
      class EquitySettingsFormCell < Decidim::ViewModel
        alias form model
  
        def content_block
          options[:content_block]
        end
  
        def label
          I18n.t("decidim.content_blocks.equity.html_content")
        end

        def title
            I18n.t("decidim.content_blocks.equity.title")
        end

        def subtitle
            I18n.t("decidim.content_blocks.equity.subtitle")
        end
      end
    end
  end