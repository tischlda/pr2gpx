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

class TestReportsListReader < MiniTest::Unit::TestCase
  def test_that_report_can_be_read
    input = <<EOS
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
    
    reader = ReportsListReader.new input
    results = reader.collect

    assert_equal 3, results.count
    expected_reports.each { |expected_report| assert_includes results, expected_report }
  end
end