class LandingPageResource < ApplicationRecord
  belongs_to :landing_page, class_name: "SiteCustomization::Page"
  belongs_to :resource, polymorphic: true
end
