# Fixes issues with the localized links:
# https://github.com/decidim/decidim/issues/4660
#
# This is no longer necessary after the bug is fixed.
Rails.application.config.to_prepare do
  Decidim::ResourceHelper.send(:include, ResourceHelperFixes)
  Decidim::ResourceLocatorPresenter.send(:include, ResourceLocatorPresenterFixes)

  url_helper_cells = [
    Decidim::ContentBlocks::HeroCell,
    Decidim::Assemblies::ContentBlocks::HighlightedAssembliesCell,
    #Decidim::Initiatives::ContentBlocks::HighlightedInitiativesCell,
    Decidim::ParticipatoryProcesses::ContentBlocks::HighlightedProcessesCell,
    Decidim::Proposals::CollaborativeDraftLinkToProposalCell,
    Decidim::ViewModel,
  ]
  url_helper_cells.each do |cell|
    cell.send(:include, EngineRouteLocales)
  end

  resource_path_cells = [
    Decidim::CardMCell,
    Decidim::Assemblies::AssemblyMCell,
    #Decidim::Consultations::ConsultationMCell,
    Decidim::ParticipatoryProcesses::ProcessGroupMCell,
    Decidim::ParticipatoryProcesses::ProcessMCell,
    Decidim::Meetings::MeetingListItemCell,
  ]
  resource_path_cells.each do |cell|
    cell.send(:include, CellResourcePaths)
  end

  # Define the resource_path helpers to point to the correct path method in the
  # cells where they have been specifically defined.
  Decidim::Assemblies::AssemblyMCell.define_resource_path(:assembly_path)
  #Decidim::Consultations::ConsultationMCell.define_resource_path(:consultation_path)
  Decidim::ParticipatoryProcesses::ProcessGroupMCell.define_resource_path(:participatory_process_group_path)
  Decidim::ParticipatoryProcesses::ProcessMCell.define_resource_path(:participatory_process_path)
end
