

Geocoder.configure(
  ip_lookup: :geoip2,
  geoip2: {
    lib: 'hive_geoip2',
    file: File.join('db/data/downloads/geoip/', 'GeoLite2-City.mmdb')
  }
)

