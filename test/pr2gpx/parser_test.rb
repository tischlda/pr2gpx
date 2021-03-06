require 'minitest/autorun'
require 'minitest/unit'
require 'date'

require_relative '../../lib/pr2gpx/parser'

class TestOutboundReportParser < MiniTest::Unit::TestCase
  def setup
    @parser = OutboundReportParser.new
    @valid_input = <<EOS
X-To: QTH
Subject: POSITION REPORT
X-WL2K-Type: Position Report
X-Priority: 2
X-MID: 3248_OE1TDA
X-Type: Radio; Outmail
Date: 02 Oct 2012 06:22:55 -0000
X-From: OE1TDA
X-Status: Sent
X-Via: HAM.Telnet.WL2K
X-Date: 2012/10/02 06:22:56

TIME: 2012/10/02 06:22
LATITUDE: 17-40.83S
LONGITUDE: 177-23.18E
COMMENT: Vuda Point Marina / Viti Levu / Fiji
EOS

    @incomplete_input = <<EOS
X-To: QTH
Subject: POSITION REPORT
X-WL2K-Type: Position Report
X-Priority: 2
X-MID: 3248_OE1TDA
X-Type: Radio; Outmail
Date: 02 Oct 2012 06:22:55 -0000
X-From: OE1TDA
X-Status: Sent
X-Via: HAM.Telnet.WL2K
X-Date: 2012/10/02 06:22:56

TIME: 2012/10/02 06:22
COMMENT: Vuda Point Marina / Viti Levu / Fiji
EOS
  end

  def test_that_report_can_be_parsed
    assert @parser.can_parse? @valid_input
  end

  def test_that_empty_report_cannot_be_parsed
    refute @parser.can_parse? ''
  end

  def test_that_report_gets_parsed
    expected_report = PositionReport.new 'OE1TDA',
                                         DateTime.new(2012, 10, 2, 6, 22, 0),
                                         Position.new('17-40.83S', '177-23.18E'),
                                         'Vuda Point Marina / Viti Levu / Fiji'
  
    results = @parser.parse(@valid_input).collect

    assert_equal 1, results.count
    assert_includes results, expected_report
  end

  def test_that_incomplete_report_gets_ignored
    results = @parser.parse(@incomplete_input).collect

    assert_equal results.count, 0
  end

  def test_that_empty_report_gets_ignored
    results = @parser.parse('').collect

    assert_equal results.count, 0
  end
end

class TestReportsListParser < MiniTest::Unit::TestCase
  def setup
    @parser = ReportsListParser.new

    @valid_input = <<EOS
X-Received: from WL2K(WL2K-2.7.3.3-B2FWIHJM$/) by OE1TDA with telnet/FBB-2/KHz id 63OTFXZZIRPC; 22 May 2012 04:55:53 -0000
X-From: SERVICE@System
X-WL2K-MBO: System
To: OE1TDA
Subject: Automated Position Request Response
X-WL2K-Date: 2012/05/22 04:55
Date: 22 May 2012 04:55:00 -0000
X-MID: 63OTFXZZIRPC
X-System-Context: HAM
Message-Id: <b17ee692053d5fbd.63OTFXZZIRPC@airmail2000.com>
X-Type: email; inmsg
X-Via: HAM.Telnet.WL2K
X-Date: 2012/05/22 04:55:54

Automated Reply Message from Winlink 2000 Position Report Processor
Processed: 2012/05/22 04:55

HB9EWT 2012/05/21 19:55 20-27.42S 179-03.49W
Comment: underway to savusavu, fiji
Speed: 5.9 knots
Course: 333T degrees

HB9EWT 2012/05/20 17:38 22-31.31S 178-27.82W
Comment: underway to savusavu, fiji
Speed: 4.8 knots
Course: 014T degrees

HB9EWT 2012/05/16 04:40 23-39.64S 178-54.46W
Comment: north minerva at anchor, caught a tuna today
Speed: 0.1 knots
Course: 045T degrees
EOS
  end

  def test_that_report_can_be_parsed
    assert @parser.can_parse? @valid_input
  end

  def test_that_empty_report_cannot_be_parsed
    refute @parser.can_parse? ''
  end

  def test_that_report_gets_parsed
    expected_reports = [
        PositionReport.new('HB9EWT',
                           DateTime.new(2012, 5, 21, 19, 55, 0),
                           Position.new('20-27.42S', '179-03.49W'),
                           'underway to savusavu, fiji'),
        PositionReport.new('HB9EWT',
                           DateTime.new(2012, 5, 20, 17, 38, 0),
                           Position.new('22-31.31S', '178-27.82W'),
                           'underway to savusavu, fiji'),
        PositionReport.new('HB9EWT',
                           DateTime.new(2012, 5, 16, 4, 40, 0),
                           Position.new('23-39.64S', '178-54.46W'),
                           'north minerva at anchor, caught a tuna today')]
    
    results = @parser.parse(@valid_input).collect

    assert_equal 3, expected_reports.count
    expected_reports.each { |expected_report| assert_includes results, expected_report }
  end
end

class TestNearbyStationsParser < MiniTest::Unit::TestCase
  def setup
    @parser = NearbyStationsParser.new

    @valid_input = <<EOS
X-Received: from WL2K(WL2K-2.7.3.5-B2FWIHJM$/) by OE1TDA with telnet/FBB-2/KHz id 0X0W40R0QTXT; 13 Sep 2012 21:12:41 -0000
X-From: SERVICE@WL2K
X-WL2K-MBO: WL2K
To: OE1TDA
Subject: INQUIRY: WL2K_NEARBY
X-WL2K-Date: 2012/09/13 21:12
Date: 13 Sep 2012 21:12:00 -0000
X-MID: 0X0W40R0QTXT
X-System-Context: HAM
Message-Id: <1332cdbd0b3cd570.0X0W40R0QTXT@airmail2000.com>
X-Type: email; inmsg
X-Via: HAM.Telnet.WL2K
X-Date: 2012/09/13 21:12:42

List of users nearby OE1TDA
 Postion: 17-05.02S  177-16.60E  posted at: 9/10/2012 10:18:00 PM
(NOTE: All dates in UTC, distance in nautical miles and bearings true great circle.)

Winlink 2000 Nearby Mobile Users
 (Only the latest report for each call within the past 10 days is listed.

CALL     Dist(nm @ DegT)        POSITION             REPORTED            COMMENT
OE1TDA         0.0 @ 000   17-05.02S 177-16.60E  2012/09/10 22:18  Narewa Bay / Naviti / Fiji
HB9TSD        16.2 @ 213   17-18.59S 177-07.36E  2012/09/12 02:35  Green Coral vor Anker Yaloba Bay, Yasawas, Fiji
VE2CCJ        32.2 @ 165   17-36.12S 177-25.44E  2012/09/12 21:07  A l'ancre a Lautoka
EOS
  end

  def test_that_report_can_be_parsed
    assert @parser.can_parse? @valid_input
  end

  def test_that_empty_report_cannot_be_parsed
    refute @parser.can_parse? ''
  end

  def test_that_report_gets_parsed
    expected_reports = [
        PositionReport.new('OE1TDA',
                           DateTime.new(2012, 9, 10, 22, 18, 0),
                           Position.new('17-05.02S', '177-16.60E'),
                           'Narewa Bay / Naviti / Fiji'),
        PositionReport.new('HB9TSD',
                           DateTime.new(2012, 9, 12, 2, 35, 0),
                           Position.new('17-18.59S', '177-07.36E'),
                           'Green Coral vor Anker Yaloba Bay, Yasawas, Fiji'),
        PositionReport.new('VE2CCJ',
                           DateTime.new(2012, 9, 12, 21, 07, 0),
                           Position.new('17-36.12S', '177-25.44E'),
                           'A l\'ancre a Lautoka')]
    
    results = @parser.parse(@valid_input).collect

    assert_equal 3, expected_reports.count
    expected_reports.each { |expected_report| assert_includes results, expected_report }
  end
end

class TestRSSParser < MiniTest::Unit::TestCase
  def setup
    @parser = RSSParser.new

    @valid_input = <<EOS
<?xml version="1.0" encoding="utf-8"?>
<rss version="2.0">
  <channel>
    <title>Winlink 2000 Position Report Map for OE1TDA</title>
    <link>http://www.winlink.org/dotnet/maps/PositionReports.aspx?callsign=OE1TDA</link>
    <description>Winlink 2000 user position reports</description>
    <ttl>60</ttl>
    <item>
      <title>Position report for OE1TDA is 17-40.83S / 177-23.18E</title>
      <description>Vuda Point Marina / Viti Levu / Fiji</description>
      <pubDate>Tue, 02 Oct 2012 06:22:00 GMT</pubDate>
      <link>http://www.winlink.org/dotnet/maps/PositionReportsDetail.aspx?callsign=OE1TDA</link>
    </item>
    <item>
      <title>Position report for OE1TDA is 17-46.23S / 177-22.90E on course 198T at a speed of 0.9</title>
      <description>Denerau Marina / Viti Levu / Fiji</description>
      <pubDate>Wed, 19 Sep 2012 22:54:00 GMT</pubDate>
      <link>http://www.winlink.org/dotnet/maps/PositionReportsDetail.aspx?callsign=OE1TDA</link>
    </item>
    <item>
      <title>Position report for OE1TDA is 17-38.54S / 177-23.61E</title>
      <description>Saweni Bay / Viti Levu / Fiji</description>
      <pubDate>Tue, 18 Sep 2012 02:41:00 GMT</pubDate>
      <link>http://www.winlink.org/dotnet/maps/PositionReportsDetail.aspx?callsign=OE1TDA</link>
    </item>
  </channel>
</rss>
EOS
  end

  def test_that_report_can_be_parsed
    assert @parser.can_parse? @valid_input
  end

  def test_that_empty_report_cannot_be_parsed
    refute @parser.can_parse? ''
  end

  def test_that_report_gets_parsed
    expected_reports = [
        PositionReport.new('OE1TDA',
                           DateTime.new(2012, 10, 2, 6, 22, 0),
                           Position.new('17-40.83S', '177-23.18E'),
                           'Vuda Point Marina / Viti Levu / Fiji'),
        PositionReport.new('OE1TDA',
                           DateTime.new(2012, 9, 19, 22, 54, 0),
                           Position.new('17-46.23S', '177-22.90E'),
                           'Denerau Marina / Viti Levu / Fiji'),
        PositionReport.new('OE1TDA',
                           DateTime.new(2012, 9, 18, 2, 41, 0),
                           Position.new('17-38.54S', '177-23.61E'),
                           'Saweni Bay / Viti Levu / Fiji')]
    
    results = @parser.parse(@valid_input).collect

    assert_equal 3, expected_reports.count
    expected_reports.each { |expected_report| assert_includes results, expected_report }
  end
end

class TestPosition < MiniTest::Unit::TestCase
  def test_that_position_can_be_created_from_strings
    cases = {
      ['0-0.0N',   '0-0.0E']    => [0.0, 0.0],
      ['12-34.5N', '123-45.6E'] => [12.575, 123.76],
      ['12-34.5S', '123-45.6W'] => [-12.575, -123.76]
    }

    cases.each do |input, expected_result|
      position = Position.new input[0], input[1]

      assert_equal expected_result[0], position.latitude
      assert_equal expected_result[1], position.longitude
    end
  end
end

class TestReportFilter < MiniTest::Unit::TestCase
  def setup
    @report = PositionReport.new('OE1TDA',
                                 DateTime.new(2012, 9, 10, 22, 18, 0),
                                 Position.new('17-05.02S', '177-16.60E'),
                                 'Narewa Bay / Naviti / Fiji')
  end

  def test_report_passes_through_when_no_filter_specified
    report_filter = ReportFilter.new nil
    
    assert report_filter.include? @report
  end

  def test_report_gets_filtered_when_callsign_not_in_filter
    report_filter = ReportFilter.new ['C1', 'C2']
    
    refute report_filter.include? @report
  end

  def test_report_passes_through_when_callsign_not_in_filter
    report_filter = ReportFilter.new ['OE1TDA', 'C2']
    
    assert report_filter.include? @report
  end
end