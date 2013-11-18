module MICP
	class Core
		def initialize(config, cmd)
			case config.service
			when :codeforces
				@service = MICP::Codeforces.new(config, cmd)
			end
		end

		def exec()
			@service.exec()
		end
	end
end
