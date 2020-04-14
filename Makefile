.PHONY:
all: output/zip-map.json

.PHONY:
clean:
	rm -rf input/*.* output/*.*

.PHONY:
install:
	pipenv sync

output/zip-map.json: input/zcta-clip.geojson
	pipenv run python scripts/zip_map.py $< > $@

input/zcta-clip.geojson: input/zcta.geojson input/clip.geojson
	mapshaper $< -clip $(filter-out $<,$^) -o $@

input/clip.geojson:
	wget -O $@ $(CLIP_GEOM)

.PRECIOUS:
input/zcta.geojson: input/cb_2017_us_zcta510_500k.shp input/zcta-states.csv
	mapshaper -i $< \
	-each "this.properties.name = this.properties.ZCTA5CE10" \
	-join $(filter-out $<,$^) keys=name,ZCTA5 field-types=ZCTA5:str \
	-filter "this.properties.STATE !== null" \
	-filter-fields name,STATE \
	-o $@

.INTERMEDIATE:
input/zcta-states.csv:
	wget -O - https://www2.census.gov/geo/docs/maps-data/data/rel/zcta_county_rel_10.txt | \
	csvcut -c ZCTA5,STATE | uniq > $@

.PRECIOUS:
input/cb_2017_us_zcta510_500k.shp: input/zcta.zip
	unzip -DD -d $(dir $@) $<

.PRECIOUS:
input/zcta.zip:
	wget --no-use-server-timestamps -O $@ http://www2.census.gov/geo/tiger/GENZ2017/shp/cb_2017_us_zcta510_500k.zip
