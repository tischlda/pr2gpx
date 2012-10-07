require 'optparse'

def parse_options argv
  options = {}

  def set_option options, name
    ->(options, name, value) { options[name] = value }.curry.(options, name)
  end

  OptionParser.new do |o|
    options[:path] = nil
    o.on '-i', '--input PATH',
      'Specifies the path to be searched for files containing position reports.',
      set_option(options, :path)

    options[:recurse] = false
    o.on '-r', '--recurse',
      'Enables recursive searching.' do
        options[:recurse] = true
      end

    options[:output] = nil
    o.on '-o', '--output [PATH]',
      'Specifies the file or directory (when using --split) to write to. Default is STDOUT.',
      set_option(options, :output)

    options[:split] = false
    o.on '-s', '--split',
      'Creates one GPX document per station. If --output is specified, it is interpreted as a directory, and one file is created per station, named [PREFIX][STATION].gpx.' do |value|
      options[:split] = value
    end

    options[:prefix] = 'PR_'
    o.on '-p', '--prefix [PREFIX]',
      'Specifies the prefix to be used when using --split, default is \'PR_\'.',
      set_option(options, :output)

    options[:callsign] = nil
    o.on '-c', '--callsign [CALLSIGN[,CALLSIGN]]', Array,
      'Processes only the stations with the given callsigns.',
      set_option(options, :callsign)

    options[:limit] = nil
    o.on '-l', '--limit [LIMIT]', Integer,
      'Limits the result to the LIMIT newest entrys for each station.',
      set_option(options, :limit)

    options[:help] = false
    o.on '-h', '--help',
      'Displays this screen.' do
      options[:help] = true
    end
    
    options[:create_trk] = options[:create_wpt] = true
    o.on '-f', '--format FORMAT[,FORMAT]', Array,
      'Selects one or more output formats. Supported values are \'TRK\', \'WPT\'.' do |values|
      values.each do |value|
        options[:create_trk] = options[:create_wpt] = false
        case(value)
          when 'TRK' then options[:create_trk] = true
          when 'WPT' then options[:create_wpt] = true
          else raise OptionParser::InvalidOption.new value
        end
      end
    end
    
    $verbose = false
    o.on '-v', '--verbose',
      'Turns on verbose mode.' do |value|
      $verbose = value
    end

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
      puts
      options[:help] = true
    end

    if options[:help]
      puts o
      return nil
    end
  end

  options
end