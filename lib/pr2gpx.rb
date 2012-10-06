require 'nokogiri'
require 'nokogiri/xml'
require 'pr2gpx/parser'
require 'optparse'

def parse_options argv
	options = {}

	def set_option options, name
		lambda { |options, name, value| options[name] = value }.curry.(options, name)
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

def load_data search_path, callsigns
	reportParser = ReportParser.new
	stations = Hash.new

	Dir
		.glob(search_path)
		.each do |filename|
			content = nil
			File.open filename do |file|
				content = file.read()
			end
			reports = reportParser.parse(content)
			if reports
				reports.each do |report|
					if not callsigns or callsigns.include? report.callsign
						stations[report.callsign] = Hash.new unless stations.has_key? report.callsign
						stations[report.callsign][report.date] = report unless stations[report.callsign].has_key? report.date
					end
				end
			end
		end

	stations
end

options = parse_options ARGV
exit if not options

search_path = "#{options[:path]}/#{options[:recurse] ? '**/' : ''}*.msg"
$stderr.puts "Searching #{search_path}" if $verbose

stations = load_data(search_path, options[:callsign])
stations.each do |callsign, reports|
	stations[callsign] = reports.values
		.sort { |report1, report2| report1.date <=> report2.date }
	stations[callsign] = stations[callsign]
		.reverse
		.take(options[:limit])
		.reverse if options[:limit]
end

def add_waypoint xml, report, element_name
	xml.send(element_name, lat: report.position.latitude, lon: report.position.longitude) do
		xml.name report.comment
		xml.time report.date
	end
end

def build_gpx stations
	builder = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
		xml.gpx(xmlns: 'http://www.topografix.com/GPX/1/1') do
			stations.each do |callsign, reports|
				xml.trk(name: callsign) do
					xml.trkseg do
						reports.each do |report|
							add_waypoint xml, report, "trkpt"
						end
					end
				end
			end
		end
	end
	builder.to_xml
end

gpx = build_gpx(stations)

if options[:output] then
	File.open options[:output], 'w:UTF-8' do |file|
		file.write gpx
	end
else
	puts gpx
end