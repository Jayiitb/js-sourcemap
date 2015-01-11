namespace :smap do
  sm = JsSourcemap::Api.new

  desc "Generate sourcemap for js files"
  task "generate_mapping" => "assets:environment" do
    sm.generate_mapping
  end

  desc "sync JS original code and mappings to s3"
  task :sync_to_s3 => :environment do
    if sm.sync_to_s3
      if asset_prefix = Rails.application.config.assets.prefix
        puts "starting sync to s3 bucket"
        puts "s3cmd sync -r private#{asset_prefix}/ s3://#{sm.env.sourcemap_config.fetch("privateassets_bucket_name")}#{asset_prefix}/ --acl-private --no-check-md5"
        if system("s3cmd sync -r private#{asset_prefix}/ s3://#{sm.env.sourcemap_config.fetch("privateassets_bucket_name")}#{asset_prefix}/ --acl-private --no-check-md5")
          puts "successfully synced assets to s3"
        else
          puts "Failed to sync asets to s3"
        end
      else
        puts "assets host not specified in application configuration"
      end
    else
      puts "Syncing to s3 disabled as per sourcemap configuration"
    end
  end
end