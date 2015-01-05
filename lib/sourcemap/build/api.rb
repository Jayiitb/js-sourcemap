require "sourcemap/env"
require "uglifier"
require "find"
require "sourcemap/build/sprockets"
require "digest/sha1"

module Sourcemap
	module Build
		class Api
			def env
				@env ||= ::Sourcemap::Env.new
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

			def create_mapping
				# empty_dirs
				Find.find(env.sources_dir) do |file|
					if File.file?(file) and File.extname(file) == ".js" and file_changed?(file)
						# uglifier = Uglifier.new(:output_filename => output_filename, :source_map_url=> source_map_url).compile(File.read(file))
						#:source_url => "SourceUrl in minified", :source_map_url => "SourceMappingUrl in minified", :source_filename => "original_file_name_in_map", :source_root=> "lol4", :output_filename => "lol5", :input_source_map => "lol6"
						smo = source_map_options file
						uglified, source_map = Uglifier.new(:source_map_url => smo["source_map_file_absolute_url"], :source_filename => smo["original_file_absolute_url"]).compile_with_map(File.read(file))
						create_min_map(smo,uglified,source_map)
						# return # check only one file
					end
				end
				write_new_hash
			end

			def create_min_map(smo, min_content,sourcem_content)
				puts "=> writing minified file : #{smo["output_filename"]} ..."
				f = File.open(smo["output_filename"], "w")
				f.write(min_content)
				f.close

				puts "=> writing sourcemap file : #{smo["source_map_file"]} ..."
				f = File.open(smo["source_map_file"], "w")
				f.write(sourcem_content)
				f.close
			end

			def source_map_options(file)
				a = Hash.new

				mapping_dirpath = get_mapping_dir file
				minified_dirpath = get_minified_dir file

				source_map_file = File.join(mapping_dirpath, File.basename(file)) + ".map"
				minified_file = File.join(minified_dirpath, File.basename(file)) + '.min'

				FileUtils.mkpath(mapping_dirpath) unless File.exists?(mapping_dirpath) # creating new mapping dir
				FileUtils.mkpath(minified_dirpath) unless File.exists?(minified_dirpath) # creating new minified dir

				a["output_filename"] = minified_file  # minified out file name
				a["source_map_file"] = source_map_file
				a["source_map_file_absolute_url"] = File.join(env.build_absolute_path source_map_file)  # map absolute url
				a["original_file_absolute_url"] = File.join(env.build_absolute_path file) # original file absolute url

				puts ">>>>>>>  file: #{file}, minified_dirpath : #{minified_dirpath}, mapping_dirpath : #{mapping_dirpath}, output_filename : #{a["output_filename"]}, source_map_file : #{a["source_map_file"]}, , source_map_file_absolute_url : #{a["source_map_file_absolute_url"]}"
				a
			end

			def get_mapping_dir(build_dir_file)
				dirpath = File.dirname(build_dir_file)
				dirpath.gsub(/.*#{env.sources_dir}/,"#{env.mapping_dir}")  # new mapping dir
			end

			def get_minified_dir(build_dir_file)
				dirpath = File.dirname(build_dir_file)
				dirpath.gsub(/.*#{env.sources_dir}/,"#{env.minified_dir}")  # new mapping dir
			end

			def write_new_hash
				puts "=> Updating hash file..."
				f = File.open(env.file_hash_path, "w")
				f.write(env.updated_hash.to_json)
				f.close
			end

			def file_changed?(file)
				# if env.file_hash[file].nil?
				# 	return true
				sha_hash = Digest::SHA1.hexdigest(File.read(file))
				if !env.file_hash[file].nil?
					if sha_hash == env.file_hash[file]
						return false
					end
				end
				env.updated_hash[file] = sha_hash
				return true
			end

			def empty_dirs
			  puts "=> Emptying #{env.mapping_dir} ..."
			  FileUtils.remove_entry_secure(env.mapping_dir, true)
			  FileUtils.mkpath env.mapping_dir
			end

			def prepend_path
			  puts "=> prepend_path"
			  assets_env = sprockets.rails_assets_env
			  assets_env.prepend_path env.mapping_dir
			  case Rails.env
			  when "development"
			    Rails.application.assets = assets_env
			  else
			    Rails.application.assets = assets_env.index
			  end
			end

			private

			def sprockets
			  @sprockets ||= ::Sourcemap::Sprockets.new
			end

		end
	end
end
