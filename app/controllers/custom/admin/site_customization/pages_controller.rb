require_dependency Rails.root.join("app", "controllers", "admin", "site_customization", "pages_controller").to_s

class Admin::SiteCustomization::PagesController < Admin::SiteCustomization::BaseController
  include ImageAttributes

  def update
    if @page.update(page_params)
      notice = t("admin.site_customization.pages.update.notice")
      if @page.landing?
        redirect_to admin_site_customization_landing_pages_path, notice: notice
      else
        redirect_to redirect_path, notice: notice
      end
    else
      find_or_create_content_cards(@page)

      flash.now[:error] = t("admin.site_customization.pages.update.error")
      render :edit
    end
  end

  def destroy
    if @page.safe_to_destroy?
      @page.destroy!
      notice = t("admin.site_customization.pages.destroy.notice")
      redirect_to admin_site_customization_pages_path, notice: notice
    else
      notice = t("custom.admin.site_customization.pages.destroy.cannot_notice")
      redirect_to admin_site_customization_pages_path, alert: notice
    end
  end

  private

    def page_params
      attributes = [
        :slug, :type, :more_info_flag,
        :print_content_flag, :status,
        :landing_show_in_top_nav,
        :landing_hide_all_top_nav_links,
        :landing_hide_title_and_subtitle,
        image_attributes: image_attributes
      ]

      params.require(:site_customization_page).permit(*attributes,
        translation_params(SiteCustomization::Page)
      )
    end

    def resource
      SiteCustomization::Page.find(params[:id])
    end

    def redirect_path
      if @page.projekt.present? && @page.published? && params[:origin] == "public_page"
        page_path(@page.slug)
      elsif @page.projekt.present?
        namespace = params[:namespace] || :admin
        namespaced_polymorphic_path(namespace, @page.projekt, action: :edit, anchor: "tab-projekt-page")
      else
        admin_site_customization_pages_path
      end
    end

    def find_or_create_content_cards(page)
      @content_cards =
        SiteCustomization::ContentCard
        .get_or_create_for_landing_page(
          page.id
        )
    end
end
