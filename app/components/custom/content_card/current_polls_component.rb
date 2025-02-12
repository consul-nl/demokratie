class ContentCard::CurrentPollsComponent < ApplicationComponent
  delegate :current_user, to: :helpers

  def initialize(content_card, custom_page: nil)
    @content_card = content_card
    @limit = content_card.settings['limit'].to_i

    @original_polls =
      if custom_page.present?
        custom_page.landing_polls
      else
        Poll.current
      end
  end

  def render?
    current_polls.any?
  end

  private

    def current_polls
      @current_polls ||=
        @original_polls
          .with_phase_feature("resource.show_on_home_page")
          .order(created_at: :asc)
    end
end
