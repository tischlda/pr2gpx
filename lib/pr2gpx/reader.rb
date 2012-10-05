require 'date'

PositionReport = Struct.new "PositionReport", :callsign, :date, :position, :comment
Position = Struct.new "Position", :latitude, :longitude

class ReportReader
	def parse input
		reader = case input
			when /List of users nearby/
				NearbyStationsReader.new
			when /Automated Reply Message from Winlink 2000 Position Report Processor/
				ReportsListReader.new
			when /Subject: POSITION REPORT/
				OutboundReportReader.new
			else
				nil
		end

		if reader
			reader.parse input
		else
			nil
		end
	end
end

class OutboundReportReader
	def parse input
		Enumerator.new do |e|
			if %r{
				(X-From:[ ](?<callsign>[^\n]*))\n
				.*
				(TIME:[ ](?<year>\d+)/(?<month>\d+)/(?<day>\d+)[ ](?<hour>\d+):(?<minute>\d+))\n
				(LATITUDE:[ ](?<latitude>[^\n]*))\n
				(LONGITUDE:[ ](?<longitude>[^\n]*))\n
				(COMMENT:[ ](?<comment>[^\n]*))}xm =~ input
	 		then
				e.yield PositionReport.new callsign,
										   DateTime.new(year.to_i, month.to_i, day.to_i, hour.to_i, minute.to_i, 0),
									 	   Position.new(latitude, longitude),
									 	   comment
			end
		end
	end
end

class ReportsListReader
	def parse input
		Enumerator.new do |e|
			input.scan %r{
				\n\n(?<callsign>\w*)[ ]
				(?<year>\d+)/(?<month>\d+)/(?<day>\d+)[ ](?<hour>\d+):(?<minute>\d+)[ ]
				(?<latitude>[^\n]*)[ ]
				(?<longitude>[^\n]*)\n
				Comment:[ ](?<comment>[^\n]*)
			}xm do |callsign, year, month, day, hour, minute, latitude, longitude, comment|
				e.yield PositionReport.new callsign,
										 DateTime.new(year.to_i, month.to_i, day.to_i, hour.to_i, minute.to_i, 0),
										 Position.new(latitude, longitude),
										 comment
			end
		end
	end
end

class NearbyStationsReader
	def parse input
		Enumerator.new do |e|
			input.scan %r{^
				(?<callsign>[^ ]*)[ ].*[ ][ ][ ]
				(?<latitude>[^ ]*)[ ]
				(?<longitude>[^ ]*)[ ][ ]
				(?<year>\d+)/(?<month>\d+)/(?<day>\d+)[ ](?<hour>\d+):(?<minute>\d+)[ ][ ]
				(?<comment>[^\n]*)
			}x do |callsign, latitude, longitude, year, month, day, hour, minute, comment|
				e.yield PositionReport.new callsign,
										 DateTime.new(year.to_i, month.to_i, day.to_i, hour.to_i, minute.to_i, 0),
										 Position.new(latitude, longitude),
										 comment
			end
		end
	end
end