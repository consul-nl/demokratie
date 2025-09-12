module Sentimentable
  extend ActiveSupport::Concern

  included do
    belongs_to :sentiment
    validates :sentiment_id, presence: true, on: :create, if: :sentiments_available?
  end

  def sentiments_available?
    return false unless projekt_phase

    projekt_phase.feature?("form.sentiments") && projekt_phase&.sentiments&.exists?
  end
end
