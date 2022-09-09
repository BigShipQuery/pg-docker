## Docker image for PostgreSQL (Beta 15.3)
### Extensions
- [PostGIS](http://postgis.net/) (3.3.0rc2)
- [Citus](https://www.citusdata.com/) (Unstable (11.1-1))
- [MobilityDB](https://mobilitydb.com/) (WIP)

## Build

```
docker buildx build --platform linux/amd64 -t pgctgisdb:local .
```