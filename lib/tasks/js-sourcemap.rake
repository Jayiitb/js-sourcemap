namespace :smap do
  sm = JsSourcemap::Api.new

  desc "Generate sourcemap for js files"
  task "generate_mapping" => "assets:environment" do
    sm.generate_mapping
  end
end