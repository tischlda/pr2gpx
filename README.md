pr2gpx
======

Converts Winlink position reports sent or received with Airmail into GPX tracks or waypoints.

pr2gpx scans a directory for files containing position reports in various formats. It can filter them to include only stations with a given callsign, and limit the results to the last N reports per station.

The output is either one track for each station, a list of waypoints for every position report, or both.

This can either be saved into a single file containing everything, or it can be split into one file for each station.


Installing
----------

First make sure you have Ruby >= 1.9 running.

Then install pr2gpx:

    gem install pr2gpx


Using
-----

Examples:

    pr2gpx --help

Displays information about the usage.


	pr2gpx --input c:\ProgramData\Airmail\Outbox

Writes all position reports in the outbox to STDOUT.


	pr2gpx --input c:\ProgramData\Airmail\Inbox --last 1 --callsign CALL1,CALL2,CALL3 --output C:\ProgramData\opencpn\layers\positions.gpx

Writes the most recent position report of CALL1, CALL2 and CALL3 into positions.gpx in C:\ProgramData\opencpn\layers.


	pr2gpx --input c:\ProgramData\Airmail\Inbox --last 10 --callsign CALL1,CALL2,CALL3 --output C:\ProgramData\opencpn\layers --split

Writes the 10 most recent position reports of CALL1, CALL2 and CALL3 into PR_CALL1.gpx, PR_CALL2.gpx and PR_CALL3.gpx in C:\ProgramData\opencpn\layers.


Developing
----------

Source: http://github.com/tischdla/pr2gpx


Copyright
---------

Copyright (c) 2012 David Tischler, licensed under the MIT License.