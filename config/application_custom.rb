module Consul
  class Application < Rails::Application
    config.time_zone = "Europe/Amsterdam"

    config.i18n.default_locale = :nl
    config.i18n.available_locales = [:nl, "fy-NL", :en]
  end
end
