class Custom::Navigation::ProposalQuizNavigationComponent < ApplicationComponent
  def initialize(resources:, projekt_phase:)
    @resources = resources
    @projekt_phase = projekt_phase
  end
end
