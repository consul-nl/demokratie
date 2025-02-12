class Admin::SiteCustomization::PagesController < Admin::SiteCustomization::BaseController
  include Translatable
  load_and_authorize_resource :page, class: "SiteCustomization::Page"

  def new
    if params[:type] == "landing"
      @page.type = "landing"
    end
  end

  def edit
    find_or_create_content_cards(@page)
  end

  def index
    @pages = SiteCustomization::Page.regular.order("slug").page(params[:page])
  end

  def create
    if @page.save
      notice = t("admin.site_customization.pages.create.notice")

      if @page.landing?
        find_or_create_content_cards(@page)

        redirect_to admin_site_customization_landing_pages_path, notice: notice
      else
        redirect_to admin_site_customization_pages_path, notice: notice
      end
    else
      flash.now[:error] = t("admin.site_customization.pages.create.error")
      render :new
    end
  end

  def update
    if @page.update(page_params)
      notice = t("admin.site_customization.pages.update.notice")

      if @page.landing?
        redirect_to admin_site_customization_landing_pages_path, notice: notice
      else
        redirect_to admin_site_customization_pages_path, notice: notice
      end
    else
      flash.now[:error] = t("admin.site_customization.pages.update.error")
      render :edit
    end
  end

  def destroy
    @page.destroy!
    notice = t("admin.site_customization.pages.destroy.notice")

    if @page.landing?
      redirect_to admin_site_customization_landing_pages_path, notice: notice
    else
      redirect_to admin_site_customization_pages_path, notice: notice
    end
  end

  private

    def page_params
      params.require(:site_customization_page).permit(allowed_params)
    end

    def allowed_params
      attributes = [:slug, :type, :more_info_flag, :print_content_flag, :status]

      [*attributes, translation_params(SiteCustomization::Page)]
    end

    def resource
      SiteCustomization::Page.find(params[:id])
    end

    def find_or_create_content_cards(page)
      @content_cards =
        SiteCustomization::ContentCard
        .get_or_create_for_landing_page(
          page.id
        )
    end
end
