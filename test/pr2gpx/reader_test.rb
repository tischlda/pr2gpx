require 'minitest/autorun'
require 'minitest/unit'
require 'date'

require_relative '../../lib/pr2gpx/reader'

class TestOutboundReportReader < MiniTest::Unit::TestCase
  def test_that_report_can_be_read
    input = <<EOS
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

	expected_report = PositionReport.new 'OE1TDA',
										 DateTime.new(2012, 10, 2, 6, 22, 0),
										 Position.new('17-40.83S', '177-23.18E'),
										 'Vuda Point Marina / Viti Levu / Fiji'
    
    reader = OutboundReportReader.new input
    results = reader.collect

    assert_equal 1, results.count
    assert_includes results, expected_report
  end

  def test_that_incomplete_report_gets_ignored
    input = <<EOS
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

    reader = OutboundReportReader.new input
    results = reader.collect

    assert_equal results.count, 0
  end
  
  def test_that_empty_report_gets_ignored
    input = ""

    reader = OutboundReportReader.new input
    results = reader.collect

    assert_equal results.count, 0
  end
end