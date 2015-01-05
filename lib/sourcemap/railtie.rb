module Sourcemap
  class Railtie < Rails::Railtie
    rake_tasks do
      load File.expand_path("../tasks/sourcemap.rake", File.dirname(__FILE__))
    end

  end
end
