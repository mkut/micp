module MICP
	module Service
		def initialize(config, cmd)
			abort("[ABORT]`#{cmd}' for #{service_name} isn't implemented or supported.") if !requirements.has_key? cmd
			config.require(*requirements[cmd])
			@cmd = cmd
			@config = config
		end

		def exec()
			self.send(@cmd)
		end

		def requirements
			{}
		end
		def service_name
			"UnkownService"
		end

	end
end
