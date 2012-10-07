require 'nokogiri'
require 'nokogiri/xml'

# Creates the GPX document from the stations hash.
#
# If create_trk is true, one trk per station gets created.
#
# If create_wpt is true, one waypoint for every report of every
# station gets created.
def build_gpx stations, create_trk, create_wpt
  builder = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
    xml.gpx(xmlns: 'http://www.topografix.com/GPX/1/1') do
      if create_trk
        stations.each do |callsign, reports|
          xml.trk do
            xml.name callsign
            xml.trkseg do
              reports.each do |report|
                xml.send('trkpt', lat: report.position.latitude, lon: report.position.longitude) do
                  xml.name report.comment
                  xml.time report.date.strftime('%FT%TZ')
                end
              end
            end
          end
        end
      end
      if create_wpt
        stations.each do |callsign, reports|
          last = reports.last
          reports.each do |report|
            xml.send('wpt', lat: report.position.latitude, lon: report.position.longitude) do
              xml.name report.callsign
              xml.desc report.comment
              xml.time report.date.strftime('%FT%TZ')
              xml.type 'WPT'
              xml.sym report == last ? 'triangle' : 'circle'
            end
          end
        end
      end
    end
  end
  builder.to_xml
end

# Writes the gpx document with UTF-8 encoding to filename.
def write_gpx filename, gpx
  $stderr.puts "Writing #{filename}" if $verbose
  File.open filename, 'w:UTF-8' do |file|
    file.write gpx
  end
end