# This is a bit of a hacky way to fix the following bug before it is fixed to
# the core:
# https://github.com/decidim/decidim/issues/4660
#
# When this module is included, it checks whether any of the engine route helper
# references are defined as methods in that class
#
# For example, if the following method is defined in the target class:
#   def decidim_participatory_processes
#     Decidim::ParticipatoryProcesses::Engine.routes.url_helpers
#   end
#
# After including this, that is swapped to:
#   def decidim_participatory_processes
#     controller.send('decidim_participatory_processes')
#   end
#
# This causes the context to be correct when these URLs are referred to fixing
# the described bug.
#
# This is no longer necessary after the bug is fixed.
module EngineRouteLocales
  extend ActiveSupport::Concern

  included do
    decidim_engines = Rails::Engine.subclasses.select { |sc|
      sc.to_s =~ /^Decidim::/ && sc.to_s !~ /::Admin::.*|::AdminEngine$/
    }
    decidim_engines.each do |engine|
      if method_defined? engine.engine_name
        define_method "#{engine.engine_name}" do
          controller.send(engine.engine_name)
        end
      end
    end

    def decidim
      controller.send(:decidim)
    end
  end
end
