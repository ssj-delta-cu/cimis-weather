# Landsat overpass example

This gives a quick example of using this data.  In particular, for a
number of Landsat overpasses, this extracts pretty much everything
you'd need to calculate ET for those dates at a set of stations.

Take a look at the Makefile for some simple example processing, or try:

```{bash}
make INFO   # Shows the dates
make all
```

The files created are:

* ```overpass.csv``` Gives the local PDT time for these overpasses

* ```station.csv``` extracts all the cimis stations, and their elevation

* ```wy201?_daily.csv``` Daily station data for the CIMIS stations.

* ```wy201?_hourly.csv``` Hourly station data for the CIMIS stations.

* ```wy201?_cimis.csv``` Hourly station data for the CIMIS stations.


