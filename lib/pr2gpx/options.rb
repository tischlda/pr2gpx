require 'optparse'

def parse_options argv
	options = {}

	def set_option options, name
		->(options, name, value) { options[name] = value }.curry.(options, name)
	end

	OptionParser.new do |o|
		options[:path] = nil
		o.on '-p', '--path PATH',
			'specify the path to be searched',
			set_option(options, :path)

		options[:recurse] = false
		o.on '-r', '--recurse',
			'enable recursive searching' do
				options[:recurse] = true
			end

		options[:output] = nil
		o.on '-o', '--output [PATH]',
			'specify the path write to. If omitted, the output is sent to STDOUT',
			set_option(options, :output)

		options[:callsign] = nil
		o.on '-c', '--callsign "[CALLSIGN[,CALLSIGN]]"', Array,
			'processes only the stations with the given callsigns',
			set_option(options, :callsign)

		options[:limit] = nil
		o.on '-l', '--limit [LIMIT]', Integer,
			'limit the result to the LIMIT newest entrys for each station',
			set_option(options, :limit)

		options[:help] = false
		o.on '-h', '--help',
			'display this screen' do
				options[:help] = true
			end
		
		$verbose = false
		o.on '-v', '--verbose',
			'turn on verbose mode' do $verbose = true end

		begin
			o.parse! argv

			if not options[:help]
				mandatory = [:path]
				missing = mandatory.select { |param| options[param].nil? }
				if not missing.empty?
					puts "Missing options: #{missing.join(', ')}"
					puts
					options[:help] = true
				end
			end
		rescue OptionParser::InvalidOption, OptionParser::MissingArgument
			puts $!.to_s
			options[:help] = true
		end

		if options[:help]
			puts o
			return nil
		end
	end

	options
end