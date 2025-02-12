class ContentCard::EventsComponent < ApplicationComponent
  delegate :current_user, to: :helpers

  def initialize(content_card, custom_page: nil)
    @content_card = content_card
    @limit = @content_card.settings['limit'].to_i

    @original_events =
      if custom_page.present?
        custom_page.landing_events
      else
        ProjektEvent.with_active_projekt
      end
  end

  def render?
    events.any?
  end

  private

    def events
      @events ||=
        @original_events
          .with_active_projekt
          .sort_by_incoming
          .first(@limit)
    end
end
