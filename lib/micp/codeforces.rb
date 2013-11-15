require 'rest_client'

module MICP
	class Codeforces
		def initialize(config)
			@csrf_token = config[:token]
			@problem = config[:problem]
			@lang_code = lang_code(config[:language])
			@source = config[:source]
			@xuserid = config[:userid]
			if !(@csrf_token && @problem && @lang_code && @source)
				puts "something wrong! [TODO]"
				exit(1)
			end
		end

		def exec(cmd)
			case cmd
			when :submit
				submit()
			end
		end

		def submit()
			response = RestClient.post("http://codeforces.com/problemset/submit?csrf_token=",
				{
					:csrf_token => @csrf_token,
					:action => 'submitSolutionFormSubmitted',
					:submittedProblemCode => @problem,
					:programTypeId => @lang_code,
					:source => '',
					:_tta => '247',
					:sourceFile => File.new(@source)
				},
				{:cookies => { 'X-User' => "#{@xuserid};" }}
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
	end
end
