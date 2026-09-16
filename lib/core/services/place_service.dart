import 'dart:convert';
import 'package:http/http.dart' as http;

class PlaceInfo {
  final String displayName;
  final String? category;
  final String? type;

  const PlaceInfo({
    required this.displayName,
    this.category,
    this.type,
  });

  @override
  String toString() => displayName;
}

class PlaceService {
  static const String _nominatimBase = 'https://nominatim.openstreetmap.org';
  static const Duration _timeout = Duration(seconds: 8);

  // Simple in-memory cache to avoid duplicate requests
  final Map<String, PlaceInfo?> _cache = {};

  /// Reverse geocode lat/lng → PlaceInfo. Returns null on any failure.
  Future<PlaceInfo?> reverseGeocode(double lat, double lng) async {
    final key = '${lat.toStringAsFixed(5)},${lng.toStringAsFixed(5)}';
    if (_cache.containsKey(key)) return _cache[key];

    try {
      final uri = Uri.parse(
        '$_nominatimBase/reverse?format=jsonv2&lat=$lat&lon=$lng&zoom=16&addressdetails=1',
      );
      final response = await http
          .get(uri, headers: {'User-Agent': 'TravelStoryApp/1.0'})
          .timeout(_timeout);

      if (response.statusCode != 200) {
        _cache[key] = null;
        return null;
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final name = json['display_name'] as String?;
      final category = json['category'] as String?;
      final type = json['type'] as String?;

      if (name == null) {
        _cache[key] = null;
        return null;
      }

      // Use short name from address when possible
      final address = json['address'] as Map<String, dynamic>?;
      final shortName = address?['amenity'] as String? ??
          address?['shop'] as String? ??
          address?['tourism'] as String? ??
          address?['historic'] as String? ??
          address?['road'] as String? ??
          address?['suburb'] as String? ??
          address?['city'] as String? ??
          name.split(',').first;

      final info = PlaceInfo(
        displayName: shortName,
        category: category,
        type: type,
      );
      _cache[key] = info;
      return info;
    } catch (_) {
      _cache[key] = null;
      return null;
    }
  }

  void clearCache() => _cache.clear();
}
