require 'date'

PositionReport = Struct.new "PositionReport", :callsign, :date, :position, :comment
Position = Struct.new "Position", :latitue, :longitude

class ReportReader
	include Enumerable

	def initialize source
		@source = source
	end
end

class OutboundReportReader < ReportReader
	def each
		if %r{
			(X-From:[ ](?<callsign>[^\n]*))\n
			.*
			(TIME:[ ](?<year>\d+)/(?<month>\d+)/(?<day>\d+)[ ](?<hour>\d+):(?<minute>\d+))\n
			(LATITUDE:[ ](?<latitude>[^\n]*))\n
			(LONGITUDE:[ ](?<longitude>[^\n]*))\n
			(COMMENT:[ ](?<comment>[^\n]*))}xm =~ @source
 		then
			yield PositionReport.new callsign,
									 DateTime.new(year.to_i, month.to_i, day.to_i, hour.to_i, minute.to_i, 0),
									 Position.new(latitude, longitude),
									 comment
		end
	end
end

class ReportsListReader < ReportReader
	def each
		puts 'ReportsListReader'
	end
end

class NearbyStationsReader < ReportReader
	def each
		puts 'NearbyStationsReader'
		return
		
		re_start = /^CALL /

		header_read = false

		@source.lines do |line|
			if !header_read then header_read = line =~ re_start
			else
				/^(?<callsign>\w{1,8}) +(?<distance>\d+\.\d+)/ =~ line
				date = 'date'
				position = 'position'
				comment = 'comment'
				yield PositionReport.new callsign, date, position, comment
			end
		end
	end
end