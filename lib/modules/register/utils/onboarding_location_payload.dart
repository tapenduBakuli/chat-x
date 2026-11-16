/// Pure builder for the onboarding Publish (PUT /users/me) `location` object.
class OnboardingLocationPayload {
  const OnboardingLocationPayload._();

  static double? _validLat(double? v) =>
      v != null && v >= -90 && v <= 90 ? v : null;
  static double? _validLng(double? v) =>
      v != null && v >= -180 && v <= 180 ? v : null;
  static String _max100(String v) => v.length > 100 ? v.substring(0, 100) : v;

  /// - State chosen: `{latitude, longitude, city, region}` with region = state
  ///   name, city = city name (null if none). Coordinates: [device] (already
  ///   range-checked by the caller, re-checked here), else the city's, else
  ///   the state's; a coordinate pair is omitted if none is valid.
  /// - No state: [device] coordinates with city/region null, else null
  ///   (the `location` key is omitted).
  static Map<String, dynamic>? build({
    String? stateName,
    String? cityName,
    double? cityLat,
    double? cityLng,
    double? stateLat,
    double? stateLng,
    ({double lat, double lng})? device,
  }) {
    final String state = (stateName ?? '').trim();
    final bool deviceOk = device != null &&
        _validLat(device.lat) != null &&
        _validLng(device.lng) != null;
    if (state.isEmpty) {
      if (!deviceOk) return null;
      return <String, dynamic>{
        'latitude': device.lat,
        'longitude': device.lng,
        'city': null,
        'region': null,
      };
    }
    final String city = (cityName ?? '').trim();
    double? lat;
    double? lng;
    if (deviceOk) {
      lat = device.lat;
      lng = device.lng;
    } else if (_validLat(cityLat) != null && _validLng(cityLng) != null) {
      lat = cityLat;
      lng = cityLng;
    } else if (_validLat(stateLat) != null && _validLng(stateLng) != null) {
      lat = stateLat;
      lng = stateLng;
    }
    return <String, dynamic>{
      'latitude': ?lat,
      'longitude': ?lng,
      'city': city.isEmpty ? null : _max100(city),
      'region': _max100(state),
    };
  }
}
