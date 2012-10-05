require 'nokogiri'
require 'pr2gpx/parser'

parser = ReportParser.new
		
stations = Hash.new

Dir
	.glob(["c:/programdata/airmail/Outbox/**/*.msg"])
	.map { |filename| File.open filename do |file| file.read() end }
	.each do |content|
		reports = parser.parse(content)
		if reports
			reports.each do |report|
				stations[report.callsign] = Hash.new unless stations.has_key? report.callsign
				stations[report.callsign][report.date] = report unless stations[report.callsign].has_key? report.date
			end
		end
	end

stations.each { |key, value| puts value.sort }