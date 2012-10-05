require 'nokogiri'
require 'pr2gpx/reader'

readers = Dir
		.glob("c:/programdata/airmail/Outbox/**/*.msg")
		.map { |filename| File.open filename do |file| file.read() end }
		.map do |content|
			case content
				when /List of users nearby/
					NearbyStationsReader.new content
				when /Automated Reply Message from Winlink 2000 Position Report Processor/
					ReportsListReader.new content
				when /Subject: POSITION REPORT/
					OutboundReportReader.new content
				else
					nil
			end
		end

enum = Enumerator.new do |e|
	readers.each do |reader|
		if reader then reader.each { |x| e.yield x } end
	end
end

stations = Hash.new

enum.each do |x|
	stations[x.callsign] = Hash.new unless stations.has_key? x.callsign
	stations[x.callsign][x.date] = x unless stations[x.callsign].has_key? x.date
end

stations.each { |key, value| puts value.sort }