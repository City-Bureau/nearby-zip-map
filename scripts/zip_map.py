import json
import sys
from collections import defaultdict
from functools import partial

import pyproj
from shapely.geometry import shape
from shapely.ops import transform


# Change projection to one that uses meters
project = partial(
    pyproj.transform, pyproj.Proj(init="epsg:4326"), pyproj.Proj(init="epsg:3857"),
)


if __name__ == "__main__":
    with open(sys.argv[1], "r") as f:
        features = json.load(f)["features"]

    zip_map = defaultdict(list)
    zctas = []
    union_buffers = []
    for feature in features:
        feature_shape = transform(project, shape(feature["geometry"]))
        # Combine a radius from the centroid with a buffer around the edges
        shape_buffer = feature_shape.buffer(1600)  # ~1 mile
        centroid_buffer = feature_shape.centroid.buffer(4000)  # ~2.5 miles

        zctas.append((feature["properties"]["name"], feature_shape))
        union_buffers.append(
            (feature["properties"]["name"], shape_buffer.union(centroid_buffer))
        )

    for buff_zip, buff_shape in union_buffers:
        for zcta_zip, zcta_shape in zctas:
            if buff_shape.intersects(zcta_shape):
                zip_map[buff_zip].append(zcta_zip)

    json.dump(zip_map, sys.stdout)
