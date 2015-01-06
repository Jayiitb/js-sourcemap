require "json"

module JsSourcemap
  class Env

    attr_accessor :sources_dir, :domain


    def initialize
      self.sources_dir = rails_path "public/assets"
      self.domain = "https://housing.com/"
    end

    def relative_path(path)
      dir = File.dirname(__FILE__)
      File.expand_path path, dir
    end

    def rails_path(path)
      "#{Rails.root}/#{path}"
    end

    def build_absolute_path(path)
      path = path.gsub(/.*(#{self.sources_dir}\/)/,'')
      "#{self.domain}assets/#{path}"
    end

  end
end
