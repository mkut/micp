require 'rest_client'

module MICP
	class Codeforces
		def initialize(config, cmd)
			config.require(*REQUIREMENTS[cmd])
			@cmd = cmd
			@config = config
		end

		def exec()
			self.send(@cmd)
		end

		def submit()
			response = RestClient.post("http://codeforces.com/problemset/submit?csrf_token=",
				{
					:csrf_token => @config[:token],
					:action => 'submitSolutionFormSubmitted',
					:submittedProblemCode => @config[:problem],
					:programTypeId => lang_code(@config[:language]),
					:source => '',
					:_tta => '247',
					:sourceFile => File.new(@config[:source])
				},
				{:cookies => { 'X-User' => "#{@config[:userid]};" }}
			) { |response, request, result, &block|
				case response.code
				when 302
					puts "submission succeeded!"
					response
				when 200
					puts "submission failed..."
					response.return!(request, result, &block)
				else
					puts "woops?"
					response
				end
			}
		end

		def new()
			Dir.mkdir(@config[:problem])
			dot_micp = File.new(File.join(@config[:problem], ".micp"), "w")
			dot_micp.puts "language: #{@config[:language]}"
			dot_micp.puts "problem: #{@config[:problem]}"
		end

		def lang_code(lang)
			if LANG_CODE.has_key? lang
				LANG_CODE[lang]
			else
				puts "error: no such language"
				exit(1)
			end
		end

		LANG_CODE = {
			"haskell" => 12
		}
		REQUIREMENTS = {
			:submit => [:token, :problem, :language, :source, :userid],
			:new    => [:problem, :language],
		}
	end
end
