Geocoder.configure(
  timeout: 10, # geocoding service timeout (secs)
  lookup: :google,
  # lookup: :pickpoint,
  api_key: 'AIzaSyC4slvWy8btLEoMcdrtVw0T3ZPX47vunN4',
  # ip_lookup: :freegeoip,      # name of IP address geocoding service (symbol)
  # language: :en,              # ISO-639 language code
  # use_https: false,           # use HTTPS for lookup requests? (if supported)
  # http_proxy: nil,            # HTTP proxy server (user:pass@host:port)
  # https_proxy: nil,           # HTTPS proxy server (user:pass@host:port)
  # cache: nil,                 # cache object (must respond to #[], #[]=, and #del)
  # cache_prefix: 'geocoder:',  # prefix (string) to use for all cache keys

  # Exceptions that should not be rescued by default
  # (if you want to implement custom error handling);
  # supports SocketError and Timeout::Error
  # always_raise: [],

  # Calculation options
  units: :km # :km for kilometers or :mi for miles
  # distances: :linear          # :spherical or :linear
)