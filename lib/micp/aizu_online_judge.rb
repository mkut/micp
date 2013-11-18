require 'rest_client'

module MICP
	class AizuOnlineJudge
		include Service

		def requirements
			REQUIREMENTS
		end

		def submit()
			RestClient.post("http://judge.u-aizu.ac.jp/onlinejudge/servlet/Submit",
				{
					:userID     => @config[:userid],
					:password   => @config[:password],
					:problemNO  => @config[:problem],
					:language   => lang_code(@config[:language]),
					:sourceCode => File.open(@config[:source], "r").read,
				}
			)
			puts "submission succeeded?"
		end
		def lang_code(lang)
			if LANG_CODE.has_key? lang
				LANG_CODE[lang]
			else
				abort("[ABORT]#{service_name} doesn't support language: `#{lang}'")
			end
		end

		LANG_CODE = {
			'c'          => 'C',
			'c++'        => 'C++',
			'java'       => 'JAVA',
			'c++0x'      => 'C++11',
			'c++11'      => 'C++11',
			'c#'         => 'C#',
			'd'          => 'D',
			'ruby'       => 'Ruby',
			'python'     => 'Python',
			'php'        => 'PHP',
			'javascript' => 'JavaScript',
		}

		REQUIREMENTS = {
			:submit => [:problem, :language, :source, :userid, :password],
			:new    => [:problem, :language],
		}
	end
end
