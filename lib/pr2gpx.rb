require 'nokogiri'
require 'nokogiri/xml'
require 'pr2gpx/parser'
require 'pr2gpx/options'

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