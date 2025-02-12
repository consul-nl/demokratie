class Admin::SiteCustomization::LandingPagesController < Admin::SiteCustomization::BaseController
  include Translatable
  load_and_authorize_resource :page, class: "SiteCustomization::Page", except: [:new]

  def new
    @page = ::SiteCustomization::Page.new(type: :landing)
    authorize! :new, @page

    find_or_create_content_cards(@page)
  end

  def index
    @pages = SiteCustomization::Page.landing.order(:slug).page(params[:page])
  end

  def edit
    @page = SiteCustomization::Page.landing.find(params[:id])
    find_or_create_content_cards(@page)
  end

  def create
    @page.type = :landing

    if @page.save
      notice = t("admin.site_customization.pages.create.notice")

      find_or_create_content_cards(@page)

      redirect_to admin_site_customization_pages_path, notice: notice
    else
      flash.now[:error] = t("admin.site_customization.pages.create.error")
      render :new
    end
  end

  def update
    if @page.update(page_params)
      notice = t("admin.site_customization.pages.update.notice")
      redirect_to admin_site_customization_landing_page_path(@page), notice: notice
    else
      flash.now[:error] = t("admin.site_customization.pages.update.error")
      render :edit
    end
  end

  def destroy
    if @page.destroy
      notice = t("admin.site_customization.pages.destroy.notice")
      redirect_to admin_site_customization_pages_path, notice: notice
    else
      flash.now[:error] = t("admin.site_customization.pages.destroy.error")
      render :edit
    end
  end

  private

    def page_params
      params.require(:site_customization_page).permit(allowed_params)
    end

    def allowed_params
      attributes = [:slug, :more_info_flag, :print_content_flag, :status]

      attributes + translation_params(SiteCustomization::Page)
    end

    def resource
      @resource ||= SiteCustomization::Page.landing.find(params[:id])
    end

    def find_or_create_content_cards(page)
      @content_cards =
        SiteCustomization::ContentCard
        .get_or_create_for_landing_page(
          page.id
        )
    end
end
