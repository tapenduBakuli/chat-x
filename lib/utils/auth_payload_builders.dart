// Pure builders (no Hive / GetX) for the optional `location` and `device`
// blocks of the register and login request bodies.

/// Max length the API accepts for `city` / `region`.
const int kMaxLocationTextLength = 100;

bool _validCoords(double? lat, double? lng) =>
    lat != null &&
    lng != null &&
    lat >= -90 &&
    lat <= 90 &&
    lng >= -180 &&
    lng <= 180;

String? _capText(String? v) {
  final String t = (v ?? '').trim();
  if (t.isEmpty) return null;
  return t.length > kMaxLocationTextLength
      ? t.substring(0, kMaxLocationTextLength)
      : t;
}

/// Register `location`: latitude/longitude (only when both are in range) and
/// city/region (trimmed, capped to 100 chars). Only keys with values are
/// included; null when nothing is left.
Map<String, dynamic>? buildRegisterLocation({
  double? latitude,
  double? longitude,
  String? city,
  String? region,
}) {
  final Map<String, dynamic> m = <String, dynamic>{};
  if (_validCoords(latitude, longitude)) {
    m['latitude'] = latitude;
    m['longitude'] = longitude;
  }
  final String? c = _capText(city);
  final String? r = _capText(region);
  if (c != null) m['city'] = c;
  if (r != null) m['region'] = r;
  return m.isEmpty ? null : m;
}

/// Login `location`: ONLY latitude + longitude (the backend rejects city /
/// region on login with 422). Null without valid coordinates.
Map<String, dynamic>? buildLoginLocation({
  double? latitude,
  double? longitude,
}) {
  if (!_validCoords(latitude, longitude)) return null;
  return <String, dynamic>{'latitude': latitude, 'longitude': longitude};
}

/// `device` block: `device_type` is always present; `device_id` may be null.
Map<String, dynamic> buildDeviceBlock({
  required String? deviceId,
  required String deviceType,
}) {
  final String id = (deviceId ?? '').trim();
  return <String, dynamic>{
    'device_id': id.isEmpty ? null : id,
    'device_type': deviceType,
  };
}

/// Appends the failing field(s) from `error.details[].field` to a 422
/// validation message. Returns [message] unchanged when there are none.
String appendErrorDetails(dynamic body, String message) {
  try {
    if (body is Map && body['error'] is Map) {
      final dynamic details = (body['error'] as Map)['details'];
      if (details is List) {
        final List<String> fields = <String>[];
        for (final dynamic d in details) {
          if (d is Map && d['field'] != null) {
            final String f = d['field'].toString().trim();
            if (f.isNotEmpty && !fields.contains(f)) fields.add(f);
          }
        }
        if (fields.isNotEmpty) return '$message (${fields.join(', ')})';
      }
    }
  } catch (_) {}
  return message;
}

/// Copy of [payload] for logging only, with secrets replaced by "***".
dynamic maskSecretsForLog(dynamic payload) {
  const Set<String> secret = <String>{
    'password',
    'confirm_password',
    'current_password',
    'new_password',
    'confirm_new_password',
    'refresh_token',
    'reset_token',
    // Card data must never reach logs (see BaseClient.post).
    'card_number',
    'cvv',
  };
  if (payload is Map) {
    return payload.map<dynamic, dynamic>((k, v) =>
        MapEntry(k, secret.contains(k) ? '***' : maskSecretsForLog(v)));
  }
  if (payload is List) return payload.map(maskSecretsForLog).toList();
  return payload;
}
