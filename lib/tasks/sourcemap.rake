namespace :smap do
  sourcemap = Sourcemap::Build::Api.new

  desc "sourcemap map creation"
  task "create_mapping" => "assets:environment" do
    sourcemap.create_mapping
  end
end
