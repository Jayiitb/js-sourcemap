require "json"

module Sourcemap
  class Env

    attr_accessor :sources_dir, :mapping_dir, :domain, :file_hash_path, :updated_hash, :minified_dir


    def initialize
      self.sources_dir = rails_path "tmp/assets_build_dir"
      self.minified_dir = rails_path "tmp/assets_min_dir"
      self.mapping_dir = rails_path "tmp/assets_map_dir"
      self.domain = "https://housing.com/"
      self.file_hash_path = relative_path "./build/file_hash.json"
      self.updated_hash = create_updated_hash
    end

    def relative_path(path)
      dir = File.dirname(__FILE__)
      File.expand_path path, dir
    end

    def rails_path(path)
      "#{Rails.root}/#{path}"
    end

    def build_absolute_path(path)
      path = path.gsub(/.*(#{self.sources_dir}\/|#{self.mapping_dir}\/|#{self.minified_dir}\/)/,'')
      "#{self.domain}assets/#{path}"
    end

    def file_hash
      if File.zero?(self.file_hash_path)
        return {}
      else
        if @hash_obj.nil?
          file = File.read(self.file_hash_path)
          @hash_obj ||= JSON.parse(file)
        end
        return @hash_obj
      end
    end

    def create_updated_hash
      if @new_hash_obj.nil?
        new_hash_obj = file_hash.clone
      end
      @new_hash_obj ||= new_hash_obj
    end

  end
end
