namespace :smap do
  sourcemap_yml = "#{Rails.root}/config/sourcemap.yml"
  config_exists = File.exists?(sourcemap_yml)
  if config_exists
    sm = JsSourcemap::Api.new
  end

  desc "Generate sourcemap for js files"
  task "generate_mapping" do
    sm.generate_mapping
  end

  desc "sync JS original code and mappings to s3"
  task :sync_to_s3 do
    sm.sync_to_s3
  end

  desc "clean Unused/Old JS files - Original & Map"
  task :clean do
    sm.clean_unused_files
  end

  desc "generate, clean and sync files to s3"
  task :complete_build do
    if config_exists
      sm.complete_build
    else
      puts "sourcemap.yml config file is not present"
    end
  end
end

Rake::Task["assets:precompile"].enhance do
  Rake::Task["smap:complete_build"].invoke
end