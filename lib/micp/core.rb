module MICP
	class Core
		def initialize(config)
			case config.service
			when :codeforces
				@service = MICP::Codeforces.new(config)
			end
		end

		def exec(cmd)
			@service.exec(cmd)
		end
	end
end
