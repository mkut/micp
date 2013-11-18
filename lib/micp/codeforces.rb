require 'rest_client'

module MICP
	class Codeforces
		include Service

		def requirements
			REQUIREMENTS
		end
		def service_name
			"Codeforces"
		end

		def submit()
			RestClient.post("http://codeforces.com/problemset/submit?csrf_token=",
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
				abort("[ABORT]#{service_name} doesn't support language: `#{lang}'")
			end
		end

		LANG_CODE = {
			"c"         => 10,
			"c++"       => 1,
			"c++0x"     => 16,
			"c++11"     => 16,
			"c#"        => 9,
			"d"         => 28,
			"delphi"    => 3,
			"go"        => 32,
			"haskell"   => 12,
			"java"      => 5,
			"java6"     => 5,
			"java7"     => 23,
			"ocaml"     => 19,
			"pascal"    => 4,
			"perl"      => 13,
			"php"       => 6,
			"python"    => 7,
			"python2.7" => 7,
			"python3.3" => 31,
			"ruby"      => 8,
			"scala"     => 20,
		}
		REQUIREMENTS = {
			:submit => [:token, :problem, :language, :source, :userid],
			:new    => [:problem, :language],
		}
	end
end
