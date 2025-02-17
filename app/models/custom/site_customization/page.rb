require_dependency Rails.root.join("app", "models", "site_customization", "page").to_s

class SiteCustomization::Page < ApplicationRecord
  self.inheritance_column = nil

  include Imageable
  attr_reader :origin

  belongs_to :projekt, touch: true

  has_many :comments, through: :projekt

  has_many :landing_page_resources, foreign_key: "landing_page_id", dependent: :destroy
  has_many :landing_projekts, through: :landing_page_resources, source: :resource, source_type: "Projekt"

  scope :regular, -> {
    where(landing: false)
  }

  scope :landing, -> {
    where(landing: true)
  }

  scope :landing_show_in_top_nav, -> {
    where(landing_show_in_top_nav: true)
  }

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

  def self.order_landing_pages(ordered_array)
    ordered_array.each_with_index do |page_id, position|
      find(page_id).update_column(:landing_nav_position, (position + 1))
    end
  end
end
