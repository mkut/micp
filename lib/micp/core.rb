module MICP
	class Core
		def initialize(config, cmd)
			case config.service
			when :codeforces
				@service = MICP::Codeforces.new(config, cmd)
			when :aizu_online_judge
				@service = MICP::AizuOnlineJudge.new(config, cmd)
			end
		end

		def exec()
			@service.exec()
		end
	end
end
