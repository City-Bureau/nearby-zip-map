# Nearby ZIP Code Mapping

Generate a JSON mapping of ZIP codes to other nearby ZIP codes. This is mainly useful for implementing a simple search by ZIP code that goes one step beyond string matching.

## Setup

You'll need GNU Make, `csvkit`, `mapshaper` and `pipenv` installed.

```bash
make install
make all CLIP_GEOM=<URL of GeoJSON file to clip with>
```
