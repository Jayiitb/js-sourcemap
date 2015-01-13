require "js-sourcemap/env"
require "uglifier"
require "find"

module JsSourcemap
	class Api
		EXTENSIONS = %w(.js)

		def env
			@env ||= ::JsSourcemap::Env.new
		end

		def config
			@config ||= Config.new(env)
		end

		def config_hash
			config.to_h
		end

		def reload!
			@env = nil
			@config = nil
		end

		def sync_to_s3?
			env.sourcemap_config.fetch("sync_to_s3") == "yes" || false
		end

		def generate_mapping
			# empty_dirs
			beginning_time = Time.now
			if !File.exists?(env.sources_dir)
				puts ">>> Directory #{env.sources_dir} doesn't exist"
				return
			end
			count = Find.find(env.sources_dir).count
			Find.find(env.sources_dir).each_with_index do |file, i|
				puts "#{i+1} of #{count} - #{file} ..........."
				if File.file?(file) and correct_file?(file)
					smo = source_map_options file
					if mapping_creation_required?(file,smo)
						copy_source(smo)
						#:source_url => "SourceUrl in minified", :source_map_url => "SourceMappingUrl in minified", :source_filename => "original_file_name_in_map", :source_root=> "lol4", :minified_file_path => "lol5", :input_source_map => "lol6"
						uglified, source_map = Uglifier.new(:source_map_url => smo["source_map_file_absolute_path"], :source_filename => smo["original_file_absolute_path"]).compile_with_map(File.read(file))
						create_min_map_gz(smo,uglified,source_map)
					end
				end
			end
			end_time = Time.now
			puts ".... Completed ......"
			puts "Time elapsed #{(end_time - beginning_time)*1000} milliseconds"
		end

		def correct_file?(file)
			return (File.extname(file) == ".js" and !(file=~/-original\.js/))
		end

		def create_min_map_gz(smo, min_content,sourcem_content)
			puts "=> writing minified file : #{smo["minified_file_path"]} ..."
			f = File.open(smo["minified_file_path"], "w")
			f.write(min_content)
			f.close

			puts "=> writing js-sourcemap file : #{smo["source_map_path"]} ..."
			f = File.open(smo["source_map_path"], "w")
			f.write(sourcem_content)
			f.close

			gz_file = "#{smo["minified_file_path"]}"
			puts "=> gzip minified file: #{gzname(gz_file)}"
			%x(gzip -c -9 "#{gz_file}" > "#{gzname(gz_file)}") if compress?(gz_file)
		end

		def compress?(file)
		  if EXTENSIONS.include?(File.extname(file))
		    !File.exists?(gzname(file)) || File.mtime(gzname(file)) < File.mtime(file)
		  end
		end

		def gzname(file)
		  "#{file}.gz"
		end

		def copy_source(smo)
			puts "=> Copying #{smo["minified_file_path"]} to #{smo["original_file_path"]}"
			FileUtils.cp(smo["minified_file_path"], smo["original_file_path"])
		end

		def source_map_options(file)
			a = Hash.new

			mapping_dirpath = get_mapping_dir file

			FileUtils.mkpath(mapping_dirpath) unless File.exists?(mapping_dirpath) # creating new mapping dir

			a["minified_file_path"] = file # something-digest.js
			a["original_file_path"] = original_file_path file  # something-digest-original.js
			a["source_map_path"] = mapping_file_path file # something-digest.js.map
			a["source_map_file_absolute_path"] = File.join(env.build_absolute_path mapping_file_path file)  # map absolute url
			a["original_file_absolute_path"] = File.join(env.build_absolute_path original_file_path file) # original file absolute url

			a
		end

		def get_mapping_dir(file)
			dirpath = File.dirname(file)
			dirpath.gsub(/.*#{env.sources_dir}/,"#{env.mapping_dir}")  # new mapping dir
		end

		def original_file_path(file)
			dirpath = get_mapping_dir file
			File.join(dirpath, File.basename(file,'.js')) + "-original.js"
		end

		def mapping_file_path(file)
			dirpath = get_mapping_dir file
			File.join(dirpath, File.basename(file)) + ".map"
		end

		def mapping_creation_required?(file,smo)
			return !(File.exists?(smo["original_file_path"]) and File.exists?(smo["source_map_path"]))
		end

		def sync_to_s3
			if sync_to_s3?
			  if asset_prefix = Rails.application.config.assets.prefix
			    puts "starting sync to s3 bucket"
			    puts "s3cmd sync -r --delete-removed --skip-existing #{env.mapping_dir}/ s3://#{env.sourcemap_config.fetch("privateassets_bucket_name")}#{asset_prefix}/ --acl-private --no-check-md5"
			    if system("s3cmd sync -r --delete-removed --skip-existing #{env.mapping_dir}/ s3://#{env.sourcemap_config.fetch("privateassets_bucket_name")}#{asset_prefix}/ --acl-private --no-check-md5")
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

		def clean_unused_files
			files = Dir[File.join(env.mapping_dir,"**","*.map")]
			files.each_with_index do |file,i|
				if env.manifest[get_relative_path(file)].nil?
					remove_files(file)
				end
			end
		end

		def remove_files(file)
			original_file = file.gsub(/\.js\.map/,'-original.js')
			puts "removing #{file} && #{original_file}"
			File.unlink(file) if File.exists?(file)
			File.unlink(original_file) if File.exists?(original_file)
		end

		def get_relative_path(file)
			file.gsub(/.*(#{env.mapping_dir}\/)/,'').gsub(/\.map/,'')
		end

	end
end
