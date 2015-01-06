require "json"

module JsSourcemap
  class Env

    attr_accessor :sources_dir, :domain, :mapping_dir, :original_dir, :is_build_dir_private


    def initialize
      self.sources_dir = rails_path "public/assets"
      self.mapping_dir = rails_path "private/assets"
      self.original_dir = rails_path "private/assets"
      # keep both dir mapping_dir and original_dir either public or private
      self.is_build_dir_private = true # false when build_dir is public/assets or app/assets or vendor/assets or lib/assets
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
      if self.is_build_dir_private
        path = path.gsub(/.*(#{Rails.root}\/)/,'')
        "#{self.domain}#{path}"
      else
        path = path.gsub(/.*(#{self.sources_dir}\/|#{Rails.root}\/|#{self.mapping_dir}\/|#{self.original_dir}\/)/,'')
        "#{self.domain}assets/#{path}"
      end
    end

  end
end
