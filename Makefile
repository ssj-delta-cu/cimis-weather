#! /usr/bin/make -f
SHELL:=/bin/bash

include appKey.mk
# appKey.mk holds your et.water.ca.gov appKey
# appKey:=[Add Here or on command line, make api_key=foobar ]

targets:=esparto fair_oaks bryte davis winters dixon \
	lodi_west twitchell_island	concord	brentwood	\
	manteca	tracy	pleasanton	modesto

esparto.id:=196
fair_oaks.id:=131
bryte.id:=155
davis.id:=6
winters.id:=139
dixon.id:=121
lodi_west.id:=166
twitchell_island.id:=140
concord.id:=170
brentwood.id:=47
manteca.id:=70
tracy.id:=167
pleasanton.id:=191
modesto.id:=71

empty:=
sp:=${empty} ${empty}
comma:=,
target_ids := $(foreach t,${targets},${$t.id})
target_ids := $(subst ${sp},|,${target_ids})

water-years:=2015
#start.2015:=2014-10-01
start.2015:=$(shell date --date='2015-10-01 - 1 year' +%Y-%m-%d)
dates.2015:=$(shell for i in `seq 0 364`; do date --date="${start.2015} + $$i days" +%Y/%m/%d; done)
months.2015:=$(shell declare -A mo; for i in ${dates.2015}; do m=$${i%/??}; mo[$$m]=1; done; echo $${!mo[@]})

sed.json:=sed -e "s/^\(.\)/.\u\1/" -e "s/\-\(.\)/\u\1/g"
items.daily:=day-air-tmp-min,day-air-tmp-max,day-air-tmp-avg,day-dew-pnt,day-eto,day-asce-eto,\
	day-precip,day-sol-rad-avg,day-sol-rad-net,day-wind-spd-avg,day-vap-pres-max,day-vap-pres-min

items.daily.json:=$(shell for i in ${items.hourly}; do echo $$i | ${sed.json}; done  )
items.daily.val:=$(patsubst %,%.Value,${items.hourly.json})
items.daily.qc:=$(patsubst %,%.QC,${items.hourly.json})
items.daily.row:=.Station,.Date,${items.daily.val},${items.daily.qc}
items.daily.header:=$(subst .,,${items.daily.row})

items.hourly:=hly-air-tmp hly-dew-pnt hly-eto hly-net-rad hly-asce-eto hly-precip\
	hly-rel-hum hly-res-wind hly-soil-tmp hly-sol-rad hly-vap-pres hly-wind-dir hly-wind-spd

items.hourly.json:=$(shell for i in ${items.hourly}; do echo $$i | ${sed.json}; done  )
items.hourly.val:=$(subst ${sp},${comma},$(patsubst %,%.Value,${items.hourly.json}))
items.hourly.qc:=$(subst ${sp},${comma},$(patsubst %,%.Qc,${items.hourly.json}))
items.hourly.row:=.Station,.Date,.Hour,${items.hourly.val},${items.hourly.qc}
items.hourly.header:=$(subst .,,${items.hourly.row})

items.cimis:=day_air_tmp_min,day_air_tmp_min_qc,day_air_tmp_max,day_air_tmp_max_qc,day_wind_spd_avg,day_wind_spd_avg_qc,day_rel_hum_max,day_rel_hum_max_qc,day_dew_pnt,day_dew_pnt_qc'

INFO:
	@echo ${items.daily}
	@echo items.daily.qc: ${items.daily.qc}
	@echo "target_ids: ${target_ids}"
	@echo "dates: ${dates.2015}"
	@echo "months: ${months.2015}"
	@echo "hourly: ${items.hourly.json}"

.PHONY:targets csv

define get_target
$(warning-no get_target $1 $2)
json.daily::daily_station/$1.wy/$2.json
csv.daily::daily_station/$1.wy/$2.csv
json.hourly:hourly_station/$1.wy/$2.json
csv.hourly:hourly_station/$1.wy/$2.csv
csv.cimis::cimis/$1.wy/$2.csv

daily_station/$1.wy/$2.json:
	http --timeout=60 GET http://et.water.ca.gov/api/data \
	  appKey==${appKey} targets==${$2.id} \
		startDate==${start.$1} endDate==$1-09-30 \
    unitOfMeasure==M dataItems==$(subst ${sp},${comma},${items.daily}) > $$@

daily_station/$1.wy/$2.csv:daily_station/$1/$2.json
	echo ${items.daily.header} > $$@
	jq -r ".Data.Providers[0].Records[] | [${items.daily.row}] | @csv" < $$< >> $$@

hourly_station/$1.wy/$2.json:
		http --timeout=240 GET http://et.water.ca.gov/api/data \
		  appKey==${appKey} targets==${$2.id} \
			startDate==${start.$1} endDate==$1-09-30 \
	    unitOfMeasure==M dataItems==$(subst ${sp},${comma},${items.hourly}) > $$@

hourly_station/$1.wy/$2.csv:hourly_station/$1.wy/$2.json
		echo ${items.hourly.header} > $$@
		jq -r ".Data.Providers[0].Records[] | [${items.hourly.row}] | @csv" < $$< >> $$@


cimis/$1.wy/$2.csv:cimis/$1.wy/station.csv
	head -n 1  $$< > $$@
	grep -P '^([\d\-.]+,){3}${$2.id},' < $$< >> $$@

clean-csv.cimis::
	rm -f cimis/$1/$2.csv

endef

$(foreach w,${water-years},$(foreach t,${targets},$(eval $(call get_target,$w,$t))))

clean-csv.cimis::
	rm -f cimis/wy2015/station.csv

cimis/wy2015/station.csv:
	  echo 'x,y,z,station_id,date,day_air_tmp_min,day_air_tmp_min_qc,day_air_tmp_max,day_air_tmp_max_qc,day_wind_spd_avg,day_wind_spd_avg_qc,day_rel_hum_max,day_rel_hum_max_qc,day_dew_pnt,day_dew_pnt_qc' > $@;
		for i in `seq 0 364`; do \
			ymd=`date --date="2014-10-01 + $$i days" +%Y/%m/%d`; \
 			echo $$ymd; \
 			http http://cimis.casil.ucdavis.edu/cimis/$$ymd/station.csv | tail -n +1 >> $@; \
		done

rast.cimis:=ETo K Rnl Rs Rso Tdew Tn Tx U2

define cimis_y
cimis.yearly:: cimis/$1/$2.tif

cimis/$1.wy/$2.tif:
		gdal_merge.py -separate -o cimis/$1.wy/$2.tif  cimis/$(shell let y=$1-1; echo $$y)/1?/$2.tif cimis/$1/0?/$2.tif

endef

define cimis_ym
cimis.monthly:: cimis/$1.wy/$2.tif

cimis/$1/$2.tif:
	gdal_merge.py -separate -o cimis/$1/$2.tif  cimis/$1/??/$2.tif

endef

define cimis
cimis.daily:: $3
$3:: cimis/$1/$2/$3.tif
cimis/$1/$3.tif:: cimis/$1/$2/$3.tif

cimis/$1/$2/$3.tif:
		[[ -d $1/$2 ]] || mkdir -p $1/$2
		http http://cimis.casil.ucdavis.edu/cimis/$1/$2/$3.asc.gz > cimis/$1/$2/$3.asc
		gdal_translate -a_srs EPSG:3310 -projwin -164000 68000 -108000 -44000 cimis/$1/$2/$3.asc cimis/$1/$2/$3.tif
		rm cimis/$1/$2/$3.asc

endef

$(foreach d,${dates.2015},$(foreach r,${rast.cimis},$(eval $(call cimis,$(dir $d),$(notdir $d),$r))))
$(foreach m,${months.2015},$(foreach r,${rast.cimis},$(eval $(call cimis_ym,$m,$r))))
$(foreach y,2015,$(foreach r,${rast.cimis},$(eval $(call cimis_y,$y,$r))))
