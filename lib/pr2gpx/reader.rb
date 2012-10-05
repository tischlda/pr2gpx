require 'date'

PositionReport = Struct.new "PositionReport", :callsign, :date, :position, :comment
Position = Struct.new "Position", :latitude, :longitude

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
		@source.scan %r{
			\n\n(?<callsign>\w*)[ ]
			(?<year>\d+)/(?<month>\d+)/(?<day>\d+)[ ](?<hour>\d+):(?<minute>\d+)[ ]
			(?<latitude>[^\n]*)[ ]
			(?<longitude>[^\n]*)\n
			Comment:[ ](?<comment>[^\n]*)
		}xm do |callsign, year, month, day, hour, minute, latitude, longitude, comment|
			yield PositionReport.new callsign,
									 DateTime.new(year.to_i, month.to_i, day.to_i, hour.to_i, minute.to_i, 0),
									 Position.new(latitude, longitude),
									 comment
		end
	end
end

class NearbyStationsReader < ReportReader
	def each
		@source.scan %r{^
			(?<callsign>[^ ]*)[ ].*[ ][ ][ ]
			(?<latitude>[^ ]*)[ ]
			(?<longitude>[^ ]*)[ ][ ]
			(?<year>\d+)/(?<month>\d+)/(?<day>\d+)[ ](?<hour>\d+):(?<minute>\d+)[ ][ ]
			(?<comment>[^\n]*)
		}x do |callsign, latitude, longitude, year, month, day, hour, minute, comment|
			yield PositionReport.new callsign,
									 DateTime.new(year.to_i, month.to_i, day.to_i, hour.to_i, minute.to_i, 0),
									 Position.new(latitude, longitude),
									 comment
		end
	end
end