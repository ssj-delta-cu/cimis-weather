# ssj-weather
CIMIS and Spatial CIMIS derived weather components.

This project summarizes weather data for water year 2015 for the Bay Delta.  The California 2015 water year goes from 2014-10-01 to 2015-09-30.   There are a number of datasets available: daily and hourly weather for a subset of CIMIS stations; the CIMIS station data used for Spatial CIMIS; and Spatial CIMIS data clipped to the Delta.

Included in the project is a Makefile for recreating all these data.  If you need a slightly different dataset, that should be helpful in processing steps.  The Makefile uses [```httpie```](http://httpie.org) and [```jq```](https://stedolan.github.io/jq/) for processing.

## Station data

We have included data from the following CIMIS stations; arranged from North to South.

Station | Station_id || Station | Station_id
--- | --- | --- | --- | ---
Esparto | 196 || Twitchell Island | 140
Fair Oaks | 131 | | Concord | 170
Bryte | 155 | | Brentwood | 47
Davis | 6 | | Manteca | 70
Winters | 139 | | Tracy | 167
Dixon | 121 | | Pleasanton | 191
Lodi West | 166 || Modesto | 71

### Daily Station ```daily_station/2015.wy/[station](.json|.csv)```

The easiest way to download CIMIS station data is via the [CIMIS API](http://et.water.ca.gov).  In order to use that, you need to [register](http://et.water.ca.gov/Home/Register/) to obtain an API key.  Once registered, creating new station data is fairly straight forward.  We simply used this API to download the data.  

 We then used ```jq``` to do a very simple process of the json data to a CSV file.  If you need another format for this infomation, consider working directly with the JSON data, as it has more complete information then the csv files. See the Makefile for complete information, ```make csv.daily```.

There is one file per station per water year.

### Hourly Station ```hourly_station/2015.wy/[station](.json|.csv)```

Similar to the ```daily_station``` data, only using calls for hourly data from the [CIMIS API](http://et.water.ca.gov).  Made with ```make csv.hourly```.  There is one file per station per water year.

## Spatial CIMIS data

The data provided here is basically the same as can be found in the [Spatial CIMIS download site](https://cimis.casil.ucdavis.edu/cimis/2015) but has been organized and reformatted.  Users can go back to the original site for more infomation.  Again, the ```Makefile``` provides useful clues for using this data.

Spatial CIMIS provides the following parameters:

parm | unit | description
--- | --- | ---
ETo | mm / d | ASCE Evapotranspiration
K | | Clear Sky Factor
Rnl | MJ/ m^2 d| Net Long Wave Radiation
Rso | MJ/ m^2 d| Calculated Clear Sky Radiation
Rs | MJ/ m^2 d | Net Short Wave Radiation
Tdew |C| Dew Point Temperature
Tn |C| Minimum Daily Temperature
Tx |C| Maximum Daily Temperature
U2 |m/s| Average Daily Wind Speed at 2m


### Station Data ```cimis/2015.wy/station.csv``` ```cimis/2015.wy/[station].csv```

It is possible that the station data used at the time of the Spatial CIMIS calculations do not match the data currently provided.  The station data used in the calculating  the Spatial CIMIS rasters is included in the ```cimis/2015.wy/``` directory.  We include the station data for each of the above Delta stations.  We also include all the data used for every day.  This data comes from the ```station.csv``` located in each directory from the [Spatial CIMIS download site](https://cimis.casil.ucdavis.edu/cimis). Made with ```make csv.cimis```.

Note the the headers for the cimis data and the station data are slightly different, but the correspondence between them is clear.


### Daily Raster data ```cimis/201[45]/MM/DD/[parm].tif```

For each day, we have downloaded, clipped, and reformatted the Spatial CIMIS rasters as GeoTiff files.  The arrangement is similar to as used in the Spatial CIMIS site.  We use ```gdal_translate```, in a manner similar to ```gdal_translate -a_srs EPSG:3310 -projwin -164000 68000 -108000 -44000 cimis/YYYY/MM/DD/ETo.asc cimis/YYYY/MM/DD/ETo.tif```.  Made with ```make cimis.daily```.

### Monthly Raster data ```cimis/201[45]/MM/[parm].tif```

For each month we combine each parameter into a multi-band tif image, one band for each day.  This is to simplify input into image processing packages, potentially.  Made with ```make cimis.monthly```.

### Yearly Raster data ```cimis/2015.wy/[parm].tif```

For each water year, we combine the months, starting from November.  To create a 365 band image of each parameter for each day.  Again this is potentially useful for image processing.

Additionally, these data are uploaded into Google Earth Engine, in the shared area for the ssj-delta-cu project. Please contact us for information on access to that data.
