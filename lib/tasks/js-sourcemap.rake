namespace :smap do
  sm = JsSourcemap::Api.new

  desc "Generate sourcemap for js files"
  task "generate_mapping" => "assets:environment" do
    sm.generate_mapping
  end

  desc "sync JS original code and mappings to s3"
  task :sync_to_s3 => :environment do
    sm.sync_to_s3
  end

  desc "clean Unused/Old JS files - Original & Map"
  task :clean => :environment do
    sm.clean_unused_files
  end
end