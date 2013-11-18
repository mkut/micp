require 'yaml'
require 'active_support/all'
require 'pathname'

module MICP
	class Config
		def service
			@configs
				.find { |c| !c.service.nil? }
				.try(:service)
		end
		def [](key)
			@configs
				.find { |c| !c.attr(service, key).nil? }
				.try(:attr, service, key) if service
		end
		def keys
			@configs
				.map { |c| c.keys(service) }
				.flatten
				.uniq if service
		end
		def require(*x)
			if x.any? { |key| self[key].nil? }
				puts "something key isn't found!"
				exit(1)
			end
		end

		def initialize(args)
			@configs = []
			path = Pathname.new(".").expand_path()
			while true
				@configs.push FileConfig.new(path + ".micp")
				break if path.root?
				path = path.parent
			end
			args.each { |argv|
				@configs.unshift StringConfig.new(argv)
			}
		end

		def to_s
			if service
				inner = keys
					.map { |key| "#{key}: #{self[key]}"}
					.join(", ")
				"#{service}/{#{inner}}"
			else
				"/{}"
			end
		end

	end

	module ConfigParameters
		TARGET_SERVICES = {
			'codeforces' => :codeforces,
			'any'        => :any,
		}
		PARAM_KEYS = {
			'problem' => :problem,
			'prob'    => :problem,
			'p'       => :problem,
			'language' => :language,
			'lang'     => :language,
			'l'        => :language,
			'source' => :source,
			's'      => :source,
			'csrf_token' => :token,
			'token'      => :token,
			'user_id' => :userid,
			'userid'  => :userid,
			'uid'     => :userid,
		}
	end

	class SingleConfig
		include ConfigParameters

		attr_reader :service
		def attr(service, key)
			_attr(service, key) || _attr(:any, key)
		end
		def _attr(service, key)
			@attr[service] && @attr[service][key]
		end
		def keys(service = nil)
			if @attr.has_key? service
				@attr[service].keys
			else
				[]
			end
		end

		def initialize
			@attr = {}
		end

		def set_attr(key, value, service = 'any')
			if TARGET_SERVICES.has_key? service
				service = TARGET_SERVICES[service]
			else
				return
			end

			if PARAM_KEYS.has_key? key
				key = PARAM_KEYS[key]
			else
				return
			end

			@attr[service] = {} if !(@attr.has_key? service)
			@attr[service][key] = value
		end
	end

	class FileConfig < SingleConfig
		def initialize(path) super()
			YAML.load(File.read(path)).each_pair { |k, v|
				if k == "service" && TARGET_SERVICES.has_key?(v)
					@service = TARGET_SERVICES[v]
				elsif TARGET_SERVICES.has_key? k
					v.each_pair { |kk, vv|
						set_attr(kk, vv, k)
					}
				else
					set_attr(k, v)
				end
			} rescue {}
		end
	end

	class StringConfig < SingleConfig
		def initialize(str) super()
			if TARGET_SERVICES.include? str
				@service = TARGET_SERVICES[str]
			elsif str =~ /(.*?)=(.*)/
				set_attr($1, $2)
			end
		end
	end
end
