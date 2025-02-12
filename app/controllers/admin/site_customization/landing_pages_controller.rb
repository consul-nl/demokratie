class Admin::SiteCustomization::LandingPagesController < Admin::SiteCustomization::BaseController
  include Translatable
  load_and_authorize_resource :page, class: "SiteCustomization::Page", except: [:new]

  def index
    @pages = SiteCustomization::Page.landing.order(:slug).page(params[:page])
  end

  private
    def find_or_create_content_cards(page)
      @content_cards =
        SiteCustomization::ContentCard
        .get_or_create_for_landing_page(
          page.id
        )
    end
end
