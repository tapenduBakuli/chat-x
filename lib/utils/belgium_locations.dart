import 'dart:convert';

import 'package:country_state_city/country_state_city.dart' as csc;
import 'package:flutter/foundation.dart' show compute, debugPrint;
import 'package:flutter/services.dart' show rootBundle;
import 'package:get/get.dart';

import 'belgium_name_match.dart';

/// country_state_city's whole-world city list (~25 MB JSON). The package's
/// getStateCities() re-reads AND re-decodes this file on the UI thread on
/// every call, which froze the UI. We read it once instead.
const String _kCscCityAsset = 'packages/country_state_city/lib/assets/city.json';

/// Runs in a background isolate (compute): decodes the city JSON and keeps
/// only Belgian cities, grouped by state code. Must be top-level for compute.
Map<String, List<Map<String, dynamic>>> belgianCitiesByState(String raw) {
  final List<dynamic> all = jsonDecode(raw) as List<dynamic>;
  final Map<String, List<Map<String, dynamic>>> out = {};
  for (final dynamic item in all) {
    if (item is Map && item['countryCode'] == 'BE') {
      final String state = (item['stateCode'] ?? '').toString();
      out.putIfAbsent(state, () => []).add(Map<String, dynamic>.from(item));
    }
  }
  return out;
}

/// Shared, cached Belgian states/cities (Browse filter + Edit Profile). The
/// big city file is loaded at most once per app run.
class BelgiumLocations {
  BelgiumLocations._();
  static final BelgiumLocations instance = BelgiumLocations._();

  final RxBool isLoading = false.obs;
  final RxBool isLoaded = false.obs;

  List<csc.State> _states = const [];
  final Map<String, List<csc.City>> _cities = {};
  Future<void>? _inFlight;

  /// States that have >= 1 city, sorted by name. Empty until loaded / on error.
  List<csc.State> get states => _states;

  /// Cities of the state with [stateIsoCode] (sorted, de-duplicated by name).
  List<csc.City> citiesOf(String stateIsoCode) =>
      _cities[stateIsoCode] ?? const [];

  csc.State? stateByName(String name) {
    for (final csc.State s in _states) {
      if (BelgiumNameMatch.same(s.name, name)) return s;
    }
    return null;
  }

  csc.City? cityByName(String stateIso, String name) {
    for (final csc.City c in citiesOf(stateIso)) {
      if (BelgiumNameMatch.same(c.name, name)) return c;
    }
    return null;
  }

  /// Single-flight load. Never throws: on error the lists stay empty.
  Future<void> ensureLoaded() {
    if (isLoaded.value) return Future<void>.value();
    return _inFlight ??= _load().whenComplete(() => _inFlight = null);
  }

  Future<void> _load() async {
    isLoading.value = true;
    try {
      final List<csc.State> all = await csc.getStatesOfCountry('BE');
      final String raw = await rootBundle.loadString(_kCscCityAsset);
      final Map<String, List<Map<String, dynamic>>> byState =
          await compute(belgianCitiesByState, raw);
      final List<csc.State> withCities = [];
      final Map<String, List<csc.City>> cities = {};
      for (final csc.State st in all) {
        final List<csc.City> c = (byState[st.isoCode] ?? const [])
            .map(csc.City.fromJson)
            .toList();
        if (c.isNotEmpty) {
          cities[st.isoCode] = _sortedUnique(c);
          withCities.add(st);
        }
      }
      withCities.sort((a, b) => a.name.compareTo(b.name));
      _cities
        ..clear()
        ..addAll(cities);
      _states = withCities;
      isLoaded.value = true;
    } catch (e) {
      debugPrint('BelgiumLocations load failed: $e');
      _states = const [];
      _cities.clear();
    } finally {
      isLoading.value = false;
    }
  }

  static List<csc.City> _sortedUnique(List<csc.City> input) {
    final Map<String, csc.City> byName = {};
    for (final csc.City c in input) {
      byName.putIfAbsent(c.name, () => c);
    }
    return byName.values.toList()..sort((a, b) => a.name.compareTo(b.name));
  }
}
