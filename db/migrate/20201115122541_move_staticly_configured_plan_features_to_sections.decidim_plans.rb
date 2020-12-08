# This migration comes from decidim_plans (originally 20201113123837)
class MoveStaticlyConfiguredPlanFeaturesToSections < ActiveRecord::Migration[5.2]
  def up
    Decidim::Component.where(manifest_name: "plans").find_each do |component|
      space = component.participatory_space
      max_position = Decidim::Plans::Section.where(
        component: component
      ).order(position: :desc).limit(1).pluck(:position).first || 0

      settings = component.read_attribute(:settings)
      global_hash = settings.is_a?(Hash) ? settings["global"] : {}
      global_hash ||= {}
      global = defaults.merge(global_hash)

      add_position = 1 # Title is always
      add_position += 1 if global["proposal_linking_enabled"]
      add_position += 1 if global["scopes_enabled"]
      add_position += 1 if global["categories_enabled"]
      add_position += 1 if global["attachments_allowed"]

      # Update the existing section positions
      Decidim::Plans::Section.where(component: component).find_each do |section|
        section.update(position: section.position + add_position)
      end

      proposals_section = nil
      title_section = nil
      scope_section = nil
      category_section = nil
      attachments_section = nil

      if global["proposal_linking_enabled"]
        proposals_section = Decidim::Plans::Section.create(
          section_attributes(
            component: component,
            type: "link_proposals",
            handle: "proposals",
            position: 0,
            body: translated_value(translations[:proposals]),
            mandatory: true
          )
        )
      end

      title_body = global["title_text"]
      title_body = translated_value(translations[:title]) if title_body.empty?
      title_help = global["title_help"]
      title_help = translated_value("") if title_help.empty?
      title_section = Decidim::Plans::Section.create(
        section_attributes(
          component: component,
          type: "field_title",
          handle: "title",
          position: 1,
          body: title_body,
          help: title_help,
          mandatory: true,
          settings: { answer_length: global["plan_title_length"].to_i }
        )
      )

      if global["scopes_enabled"]
        scope = Decidim::Scope.find_by(id: global["scope_id"]) || space&.scope
        scope_section = Decidim::Plans::Section.create(
          section_attributes(
            component: component,
            type: "field_scope",
            handle: "scope",
            position: 2,
            body: translated_value(translations[:scope]),
            mandatory: true,
            settings: { scope_parent: scope&.id }
          )
        )
      end

      if global["categories_enabled"]
        category_section = Decidim::Plans::Section.create(
          section_attributes(
            component: component,
            type: "field_category",
            handle: "category",
            position: 3,
            body: translated_value(translations[:category]),
            mandatory: true
          )
        )
      end

      if global["attachments_allowed"]
        attachments_section = Decidim::Plans::Section.create(
          section_attributes(
            component: component,
            type: "field_attachments",
            handle: "attachments",
            position: max_position + add_position + 1,
            body: translated_value(translations[:attachments]),
            help: translated_value(global["attachment_help"]),
            settings: { attachments_input_type: "multi" }
          )
        )
      end

      # Go through all the plans and move the values to the content elements
      Decidim::Plans::Plan.where(component: component).find_each do |plan|
        if proposals_section
          proposal_ids = plan.linked_resources(:proposals, "included_proposals").map(&:id)
          plan.contents.create(
            section: proposals_section,
            body: { proposal_ids: proposal_ids }
          )
        end
        if scope_section
          plan.contents.create(
            section: scope_section,
            body: { scope_id: plan.decidim_scope_id }
          )
        end
        if category_section
          plan.contents.create(
            section: category_section,
            body: { category_id: plan.decidim_category_id }
          )
        end
        if attachments_section
          attachment_ids = plan.attachments.map(&:id)
          plan.contents.create(
            section: attachments_section,
            body: { attachment_ids: attachment_ids }
          )
        end
      end
    end
  end

  def down
    Decidim::Component.where(manifest_name: "plans").find_each do |component|
      settings = component.read_attribute(:settings)
      global_hash = settings.is_a?(Hash) ? settings["global"] : {}
      global_hash ||= {}
      global = defaults.merge(global_hash)

      proposals_section = Decidim::Plans::Section.find_by(component: component, handle: "proposals")
      title_section = Decidim::Plans::Section.find_by(component: component, handle: "title")
      scope_section = Decidim::Plans::Section.find_by(component: component, handle: "scope")
      category_section = Decidim::Plans::Section.find_by(component: component, handle: "category")
      attachments_section = Decidim::Plans::Section.find_by(component: component, handle: "attachments")

      if proposals_section
        global["proposal_linking_enabled"] = true
        proposals_section.destroy
      end
      if title_section
        global["title_text"] = title_section.body
        global["title_hash"] = title_section.help
        global["plan_title_length"] = proposals_section.settings["answer_length"]
        title_section.destroy
      end
      if scope_section
        global["scopes_enabled"] = true
        global["scope_id"] = scope_section.body["scope_id"]
        scope_section.destroy
      end
      if category_section
        global["categories_enabled"] = true
        category_section.destroy
      end
      if attachments_section
        global["attachments_allowed"] = true
        global["attachment_help"] = attachments_section.help
        attachments_section.destroy
      end

      settings["global"] = global
      component.write_attribute(:settings, settings)
      component.save(validate: false)
    end
  end

  private

  def defaults
    @defaults ||= {
      "attachment_help" => {},
      "attachments_allowed" => false,
      "categories_enabled" => true,
      "plan_title_length" => 150,
      "proposal_linking_enabled" => true,
      "scope_id" => nil,
      "scopes_enabled" => true,
      "title_help" => {},
      "title_text" => {}
    }
  end

  def translated_value(localized)
    {}.tap do |hash|
      Decidim.available_locales.each do |locale|
        hash[locale.to_s] = localized[locale.to_s] || localized["en"]
      end
    end
  end

  def section_attributes(
    component:,
    type:,
    handle:,
    position:,
    body: nil,
    mandatory: false,
    help: nil,
    settings: {}
  )
    {
      component: component,
      section_type: type,
      handle: handle,
      mandatory: mandatory,
      position: position,
      body: body || translated_value(""),
      help: help || translated_value(""),
      information_label: translated_value(""),
      information: translated_value(""),
      visible_form: true,
      visible_view: true,
      visible_api: false,
      settings: settings
    }
  end

  def translations
    @translations ||= {
      attachments: {
        "en" => "Add an attachment",
        "fi" => "Lisää liite",
        "sv" => "Lägg till bilaga"
      },
      category: {
        "en" => "Category",
        "fi" => "Kategoria",
        "sv" => "Kategori"
      },
      proposals: {
        "en" => "Proposals",
        "fi" => "Ehdotukset",
        "sv" => "Förslag"
      },
      scope: {
        "en" => "Scope",
        "fi" => "Teema",
        "sv" => "Tema"
      },
      title: {
        "en" => "Title",
        "fi" => "Otsikko",
        "sv" => "Titel"
      }
    }
  end
end
