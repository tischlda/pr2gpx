require 'pr2gpx/options'
require 'pr2gpx/parser'
require 'pr2gpx/gpx'

# Creates an Enumerable with one entry for every file in search_path,
# containing the files content.
def enumerate_files search_path
  Enumerator.new do |e|
    Dir
      .glob(search_path)
      .each do |filename|
        if File.file?(filename)
          $stderr.puts "Reading #{filename}" if $verbose
          File.open filename do |file|
            e.yield file.read()
        end
      end
    end
  end
end

# Runs each element of content_enum through ReportParser::parse,
# receiving an Enumerable of PositionReport. If the report passes
# through the filter, it is added to the hash of the station, if
# no other report with the same date exists.
#
# Those hashes are stored in another hash, indexed by callsign,
# which gets returned.
def load_data content_enum, filter
  reportParser = ReportParser.new
  stations = Hash.new

  content_enum.each do |content|
    reports = reportParser.parse(content)
    if reports
      reports.each do |report|
        if filter.include? report
          $stderr.print 'o' if $verbose
          stations[report.callsign] = Hash.new unless stations.has_key? report.callsign
          stations[report.callsign][report.date] = report unless stations[report.callsign].has_key? report.date
        else
          $stderr.print '.' if $verbose
        end
      end
    end
    $stderr.puts if $verbose
  end

  stations
end

# Converts the reports the entries of the stations-hash, which are
# hashes indexed by date, into arrays sorted by date.
#
# The parameter last can be used to limit the reports to the N
# most recent ones.
def filter_data! stations, last
  stations.each do |callsign, reports|
    stations[callsign] = reports.values
      .sort { |report1, report2| report1.date <=> report2.date }
    
    stations[callsign] = stations[callsign]
      .reverse
      .take(last)
      .reverse if last
  end
end

options = parse_options ARGV
exit if not options

errors = validate_options(options)
if errors
  $stderr.puts errors
  exit
end

# normalize path separators
options[:input].gsub!('\\', '/')
options[:output].gsub!('\\', '/') if options[:output]

filter = ReportFilter.new options[:callsign]

search_path = if File.directory?(options[:input])
  "#{options[:input]}/#{options[:recurse] ? '**/' : ''}*.*"
else
  options[:input]
end

$stderr.puts "Searching #{search_path}" if $verbose

stations = load_data(enumerate_files(search_path), filter)
filter_data! stations, options[:last]

if options[:split] # create one document for each station
  stations.each do |callsign, reports|
    gpx = build_gpx({ callsign => reports }, options[:create_trk], options[:create_wpt])

    if options[:output] then
      write_gpx "#{options[:output]}/#{options[:prefix]}#{callsign}.gpx", gpx
    else
      puts gpx
    end
  end
else # create one document for all data
  gpx = build_gpx(stations, options[:create_trk], options[:create_wpt])

  if options[:output] then
    write_gpx options[:output], gpx
  else
    puts gpx
  end
end