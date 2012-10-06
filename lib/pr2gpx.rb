require 'nokogiri'
require 'nokogiri/xml'
require 'pr2gpx/parser'
require 'pr2gpx/options'

def enumerate_files search_path
  Enumerator.new do |e|
    Dir
      .glob(search_path)
      .each do |filename|
        File.open filename do |file|
          e.yield file.read()
      end
    end
  end
end

def load_data content_enum, filter
  reportParser = ReportParser.new
  stations = Hash.new

  content_enum.each do |content|
    reports = reportParser.parse(content)
    if reports
      reports.each do |report|
        if filter.include? report
          stations[report.callsign] = Hash.new unless stations.has_key? report.callsign
          stations[report.callsign][report.date] = report unless stations[report.callsign].has_key? report.date
        end
      end
    end
  end

  stations
end

def filter_data! stations, limit
  stations.each do |callsign, reports|
    stations[callsign] = reports.values
      .sort { |report1, report2| report1.date <=> report2.date }
    
    stations[callsign] = stations[callsign]
      .reverse
      .take(limit)
      .reverse if limit
  end
end

options = parse_options ARGV
exit if not options

search_path = "#{options[:path]}/#{options[:recurse] ? '**/' : ''}*.msg"
$stderr.puts "Searching #{search_path}" if $verbose

filter = ReportFilter.new options[:callsign]

stations = load_data(enumerate_files(search_path), filter)
filter_data! stations, options[:limit]

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