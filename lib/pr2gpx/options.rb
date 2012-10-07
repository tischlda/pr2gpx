require 'optparse'

# If options are valid, returns a hash of options, otherwise nil.
def parse_options argv
  options = {}
  mandatory = [:input]

  def set_option options, name
    ->(options, name, value) { options[name] = value }.curry.(options, name)
  end

  OptionParser.new do |o|
    options[:input] = nil
    o.on '-i', '--input PATH',
      'Specifies the path to be searched for files containing position reports.',
      set_option(options, :input)

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

    options[:last] = nil
    o.on '-l', '--last [n]', Integer,
      'Limits the result to the last N entries for each station.',
      set_option(options, :last)

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

# If errors are encountered, returns an array of error messages, otherwise nil.
def validate_options options
  errors = []

  if not File.exists?(options[:input])
    errors << 'Path specified in --input does not exist.'
  elsif not File.directory?(options[:input])
    errors << 'Path specified in --input is not a directory.'
  end

  if options[:split]
    if not File.exists?(options[:output])
      errors << 'Path specified in --output does not exist.'
    elsif not File.directory?(options[:output])
      errors << 'Path specified in --output is not a directory.'
    end
  else
    if not File.exists?(File.dirname(options[:output]))
      errors << 'Path specified in --output does not exist.'
    elsif File.directory?(options[:output])
      errors << 'Path specified in --output is a directory.'
    end
  end

  errors if errors.length > 0
end