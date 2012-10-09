pr2gpx
======

Converts Winlink position reports into GPX tracks or waypoints.

pr2gpx understands position report data downloaded as RSS documents from the [Winlink 2000](http://www.winlink.org/) website using this Url:

	http://www.winlink.org/dotnet/maps/RSSPositionReports.aspx?callsign=[callsign]

It also understands the information contained in messages sent or received with the [AirMail](http://siriuscyber.net/airmail/) client program:
- sent position reports (Window->Winlink-2000->Position Report)
- reports requested for specific stations (Window->Winlink-2000->Position Request)
- lists of nearby stations (Window->Catalogs->WL2K->Global->WL2K_USERS->WL2K_NEARBY)

pr2gpx can either be given one file to parse, or it can scan all files in a directory. It can filter the data to include only stations with a given callsign, and limit the results to the last N reports per station.

The output is either one track for each station, a list of waypoints for every position report, or both.

The results can either be saved into a single file containing everything, or it can be split into one file for each station.

If no input path is given, pr2gpx reads from STDIN. If no output path is given, pr2gpx writes to STDOUT.


Installing
----------

First make sure you have Ruby >= 1.9 running.

Then install pr2gpx:

    gem install pr2gpx


Using
-----

    pr2gpx --help

Displays information about the usage.


	pr2gpx --input c:\ProgramData\Airmail\Outbox

Writes all position reports in the outbox to STDOUT.


	pr2gpx --input c:\ProgramData\Airmail\Inbox --last 1 --callsign CALL1,CALL2,CALL3 --output C:\ProgramData\opencpn\layers\positions.gpx

Writes the most recent position report of CALL1, CALL2 and CALL3 into positions.gpx in C:\ProgramData\opencpn\layers.


	pr2gpx --input c:\ProgramData\Airmail\Inbox --last 10 --callsign CALL1,CALL2,CALL3 --output C:\ProgramData\opencpn\layers --split

Writes the 10 most recent position reports of CALL1, CALL2 and CALL3 into PR_CALL1.gpx, PR_CALL2.gpx and PR_CALL3.gpx in C:\ProgramData\opencpn\layers.


	curl http://www.winlink.org/dotnet/maps/RSSPositionReports.aspx?callsign=CALL1 | pr2gpx --last 5 --output C:\ProgramData\opencpn\layers --split

Downloads the data for CALL1 from Winlink and writes the 5 most recent position reports into PR_CALL1.gpx in C:\ProgramData\opencpn\layers.


Developing
----------

Source: http://github.com/tischdla/pr2gpx


Run tests:

	rake test


Create gem package:

	rake package


Copyright
---------

Copyright (c) 2012 David Tischler, licensed under the MIT License.