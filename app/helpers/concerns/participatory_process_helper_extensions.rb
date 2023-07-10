# frozen_string_literal: true

# Extensions for the Decidim::ParticipatoryProcesses::ParticipatoryProcessHelper
module ParticipatoryProcessHelperExtensions
  extend ActiveSupport::Concern

  def process_step_tag(step, past: false)
    cls = ["phases-list-item"]
    if past
      cls << "phases-list-item-past"
    elsif step.active?
      cls << "phases-list-item-current"
    end

    if current_component && step.cta_path.present?
      cls << "phases-list-item-active" if step.cta_path =~ %r{^f/#{current_component.id}(/.*)?$}
    elsif current_participatory_space.blank?
      # When displayed outside of a participatory space, the active state is
      # shown for the active step instead of the active page.
      # cls << "phases-list-item-active" if step.active?
    end

    content_tag :li, class: cls.join(" ") do
      yield
    end
  end

  def process_step_link(step)
    if step.cta_path.present?
      step_url = begin
        base_url, current_params = decidim_participatory_processes.participatory_process_path(
          step.participatory_process
        ).split("?")

        if current_params.present?
          [base_url, "/", step.cta_path, "?", current_params].join
        else
          [base_url, "/", step.cta_path].join
        end
      end

      link_to step_url do
        yield
      end
    else
      capture do
        yield
      end
    end
  end

  def step_date_info(step)
    cta_text = translated_attribute(step.cta_text)
    return cta_text if cta_text.present?

    step_dates(step)
  end
end
