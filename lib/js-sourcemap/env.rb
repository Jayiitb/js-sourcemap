require "json"

module JsSourcemap
  class Env

    attr_accessor :sources_dir, :domain, :mapping_dir, :is_build_dir_private, :sourcemap_yml, :manifest


    def initialize
      self.sources_dir = rails_path "public#{Rails.application.config.assets.prefix}"
      self.sourcemap_yml = rails_path "config/sourcemap.yml"
      self.mapping_dir = rails_path "#{sourcemap_config.fetch "mapping_directory"}#{Rails.application.config.assets.prefix}"
      self.domain = sourcemap_config.fetch "domain"
      self.manifest = get_manifest_file
    end

    def sourcemap_config
      @sourcemap_config ||= load_config
    end

    def config_path
      @config_path ||= Pathname.new(self.sourcemap_yml)
    end

    def readable?
      config_path.readable?
    end

    def load_config
      return {} if not readable?
      File.open config_path do |f|
        YAML.load f.read
      end
    end

    def relative_path(path)
      dir = File.dirname(__FILE__)
      File.expand_path path, dir
    end

    def rails_path(path)
      "#{Rails.root}/#{path}"
    end

    def get_manifest_file
      return @manifest_hash if @manifest_hash
      files = Dir[File.join(self.sources_dir,"manifest*")]
      if files and files.length == 1
        file = File.read(files.first)
        @manifest_hash = JSON.parse(file)["files"]
      else
        puts "Either none or more than one minifest file exists"
      end

    end

    def build_absolute_path(path)
        path = path.gsub(/.*(#{self.sources_dir}\/|#{self.mapping_dir}\/)/,'')
        path = "#{Rails.application.config.assets.prefix}/#{path}"
        "#{self.domain}#{path}"
    end

  end
end
