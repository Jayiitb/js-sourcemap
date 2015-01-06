module JsSourcemap
  class Railtie < Rails::Railtie
    rake_tasks do
      load File.expand_path("../tasks/js-sourcemap.rake", File.dirname(__FILE__))
    end

  end
end
