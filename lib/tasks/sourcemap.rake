namespace :smap do
  sourcemap = Sourcemap::Api.new

  desc "sourcemap map creation"
  task "generate_mapping" => "assets:environment" do
    sourcemap.generate_mapping
  end
end
