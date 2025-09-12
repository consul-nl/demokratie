unless Rails.env.test?
  require "database_cleaner"
  DatabaseCleaner.clean_with :truncation
end
@logger = Logger.new(STDOUT)
@logger.formatter = proc do |_severity, _datetime, _progname, msg|
                      msg unless @avoid_log
                    end

def section(section_title)
  @logger.info section_title
  yield
  log(" ✅")
end

def log(msg)
  @logger.info "#{msg}\n"
end

def random_locales
  [I18n.default_locale, *(I18n.available_locales & %i[en es]), *I18n.available_locales.sample(4)].uniq.take(5)
end

def random_locales_attributes(**attribute_names_with_values)
  random_locales.each_with_object({}) do |locale, attributes|
    I18n.with_locale(locale) do
      attribute_names_with_values.each do |attribute_name, value_proc|
        attributes["#{attribute_name}_#{locale.to_s.underscore}"] = value_proc.call
      end
    end
  end
end

require_relative "dev_seeds/settings"
require_relative "dev_seeds/projekts"
require_relative "dev_seeds/geozones"
require_relative "dev_seeds/users"
require_relative "dev_seeds/tags_categories"
require_relative "dev_seeds/debates"
require_relative "dev_seeds/proposals"
require_relative "dev_seeds/budgets"
require_relative "dev_seeds/comments"
require_relative "dev_seeds/votes"
require_relative "dev_seeds/flags"
require_relative "dev_seeds/hiddings"
require_relative "dev_seeds/banners"
require_relative "dev_seeds/polls"
require_relative "dev_seeds/communities"
require_relative "dev_seeds/legislation_processes"
require_relative "dev_seeds/newsletters"
require_relative "dev_seeds/notifications"
require_relative "dev_seeds/widgets"
require_relative "dev_seeds/admin_notifications"
require_relative "dev_seeds/legislation_proposals"
require_relative "dev_seeds/milestones"
require_relative "dev_seeds/pages"
require_relative "dev_seeds/sdg"

# Default admin user (change password after first deploy to a server!)
if Administrator.count == 0 && !Rails.env.test?
  admin = User.create!(username: "admin", email: "admin@consul.dev", password: "Aa12345678",
                       password_confirmation: "Aa12345678", confirmed_at: Time.current,
                       terms_data_storage: "1", terms_data_protection: "1", terms_general: "1", terms_older_than_14: "1")
  admin.create_administrator
end

Setting.reset_defaults

Projekt.find_or_create_by!(name: "Overview page", special_name: "projekt_overview_page", special: true)

load Rails.root.join("db", "web_sections.rb")

# Default custom pages
load Rails.root.join("db", "pages.rb")

# Sustainable Development Goals
load Rails.root.join("db", "sdg.rb")

# Default custom content blocks
load Rails.root.join("db", "content_blocks.rb")

log "All dev seeds created successfuly 👍"
