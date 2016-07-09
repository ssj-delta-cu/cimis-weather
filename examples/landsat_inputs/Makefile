#! /usr/bin/make -f
SHELL:=/bin/bash

station_url:=http://et.water.ca.gov/api/station

wy2015.dates:=2014-10-12 2014-10-28 2014-12-31 \
2015-03-05 2015-03-21 2015-04-22 2015-05-08 2015-05-24 \
2015-06-25 2015-07-11 2015-07-27 2015-08-12 2015-09-29

wy2014.dates:=2014-09-10

base:=../..
wy2015.hsdir:=${base}/hourly_station/2015.wy
wy2014.hsdir:=${base}/hourly_station/2014.wy_partial
wy2014.dsdir:=${base}/daily_station/2014.wy_partial
wy2015.dsdir:=${base}/daily_station/2015.wy
wy2014.csdir:=${base}/cimis/2014.wy_partial
wy2015.csdir:=${base}/cimis/2015.wy
stations:=$(shell cd ${wy2015.hsdir}; ls *.csv | sed -e 's/\.csv//')
hour:=1[012]00

INFO::
	@echo stations:=${stations}
	@echo wy2014.dates:=${wy2014.dates}
	@echo wy2015.dates:=${wy2015.dates}

all: overpass.csv station.csv wy2014_daily.csv wy2015_daily.csv wy2014_hourly.csv wy2015_hourly.csv wy2014_cimis.csv wy2015_cimis.csv

overpass.csv:
	for d in ${wy2014.dates} ${wy2015.dates}; do \
	  pdt=`TZ='America/Los_Angeles' date --date="$$d 18:45 GMT" +%H:%M`; \
	  echo $$d,$$pdt; \
	done > $@

station.csv:
	echo station,name,elevation,hms_lon,longitude,hms_lat,latitude > $@
	curl ${station_url} | jq  -r '.Stations[] | [.StationNbr,.Name,.Elevation,.HmsLongitude,.HmsLatitude] | @csv' | sed -e 's| / |","|g' >> $@

wy2014_daily.csv wy2015_daily.csv:%_daily.csv:
	echo 'Station,Date,DayAirTmpMinValue,DayAirTmpMaxValue,DayAirTmpAvgValue,DayDewPntValue,DayEtoValue,DayAsceEtoValue,DayPrecipValue,DaySolRadAvgValue,DaySolRadNetValue,DayWindSpdAvgValue,DayVapPresMaxValue,DayVapPresMinValue,DayAirTmpMinQc,DayAirTmpMaxQc,DayAirTmpAvgQc,DayDewPntQc,DayEtoQc,DayAsceEtoQc,DayPrecipQc,DaySolRadAvgQc,DaySolRadNetQc,DayWindSpdAvgQc,DayVapPresMaxQc,DayVapPresMinQc' > $@;
	@for s in ${stations}; do \
	  for d in ${$*.dates}; do \
	    grep $$d < ${$*.dsdir}/$$s.csv; \
	  done; \
	done >> $@;

wy2014_hourly.csv wy2015_hourly.csv:%_hourly.csv:
	echo 'Station,Date,Hour,HlyAirTmpValue,HlyDewPntValue,HlyEtoValue,HlyNetRadValue,HlyAsceEtoValue,HlyPrecipValue,HlyRelHumValue,HlyResWindValue,HlySoilTmpValue,HlySolRadValue,HlyVapPresValue,HlyWindDirValue,HlyWindSpdValue,HlyAirTmpQc,HlyDewPntQc,HlyEtoQc,HlyNetRadQc,HlyAsceEtoQc,HlyPrecipQc,HlyRelHumQc,HlyResWindQc,HlySoilTmpQc,HlySolRadQc,HlyVapPresQc,HlyWindDirQc,HlyWindSpdQc' > $@;
	@for s in ${stations}; do \
	  for d in ${$*.dates}; do \
	    grep $$d < ${$*.hsdir}/$$s.csv | grep ',"${hour}",'; \
	  done; \
	done >> $@;

wy2014_cimis.csv wy2015_cimis.csv:%_cimis.csv:
	echo 'x,y,z,station_id,date,day_air_tmp_min,day_air_tmp_min_qc,day_air_tmp_max,day_air_tmp_max_qc,day_wind_spd_avg,day_wind_spd_avg_qc,day_rel_hum_max,day_rel_hum_max_qc,day_dew_pnt,day_dew_pnt_qc' > $@;
	@for s in ${stations}; do \
	  for d in ${$*.dates}; do \
	    grep $$d < ${$*.dsdir}/$$s.csv; \
	  done; \
	done >> $@;

