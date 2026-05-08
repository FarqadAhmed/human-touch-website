import 'dart:convert';
import 'package:http/http.dart' as http;

import 'accessible_place.dart';

class AccessiblePlacesService {
  static const String baseUrl =
      'https://us-central1-human-touch-35bd0.cloudfunctions.net/searchAccessiblePlaces';

  Future<List<AccessiblePlace>> searchPlaces({
    required String query,
    required double userLat,
    required double userLng,
  }) async {
    final uri = Uri.parse(baseUrl);

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'query': query,
        'userLat': userLat,
        'userLng': userLng,
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Search failed: ${response.body}');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;

    final results = (decoded['results'] as List<dynamic>? ?? [])
        .map((item) => AccessiblePlace.fromJson(item as Map<String, dynamic>))
        .toList();

    return results;
  }
}
