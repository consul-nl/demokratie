require_dependency Rails.root.join("app", "models", "site_customization", "page").to_s

class SiteCustomization::Page < ApplicationRecord
  self.inheritance_column = nil

  include Imageable
  attr_reader :origin

  belongs_to :projekt, touch: true

  has_many :comments, through: :projekt

  enum type: {
    regular: "regular",
    landing: "landing"
  }

  has_many :landing_page_resources, foreign_key: "landing_page_id", dependent: :destroy
  has_many :landing_projekts, through: :landing_page_resources, source: :resource, source_type: "Projekt"
  has_many :landing_events, through: :landing_page_resources, source: :resource, source_type: "ProjektEvent"
  has_many :landing_polls, through: :landing_page_resources, source: :resource, source_type: "Poll"

  def draft?
    status == 'draft'
  end

  def published?
    status == 'published'
  end

  def comments_count
    comments.count
  end

  def full_url
    Setting['url'].chomp('/') + "/#{slug}"
  end

  def safe_to_destroy?
    projekt.blank?
  end
end
