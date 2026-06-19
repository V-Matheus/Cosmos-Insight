import '../models/asteroid.dart';
import 'nasa_api_client.dart';

/// Talks to NASA's NeoWs (Near Earth Object Web Service) and maps the JSON into
/// [Asteroid] value objects the UI can render directly.
///
/// Docs: https://api.nasa.gov (Asteroids - NeoWs)
class NeoService {
  NeoService({NasaApiClient? client}) : _client = client ?? NasaApiClient();

  final NasaApiClient _client;

  /// Browses the overall NEO catalogue (paginated). Used by the Asteroids tab
  /// as a "live catalogue". Each object's nearest approach is surfaced.
  Future<List<Asteroid>> browse({int page = 0, int size = 20}) async {
    final json = await _client.getJson(
      '/neo/rest/v1/neo/browse',
      query: {'page': '$page', 'size': '$size'},
    );
    final objects = (json['near_earth_objects'] as List?) ?? const [];
    return objects
        .cast<Map<String, dynamic>>()
        .map((o) => Asteroid.fromJson(o, closest: true))
        .toList();
  }

  /// Fetches the NEO feed for a single [date] (`YYYY-MM-DD`). Used by the NEO
  /// Feed Query tab. Results are sorted by miss distance (closest first).
  Future<List<Asteroid>> feed(String date) async {
    final json = await _client.getJson(
      '/neo/rest/v1/feed',
      query: {'start_date': date, 'end_date': date},
    );
    final byDate =
        (json['near_earth_objects'] as Map?)?[date] as List? ?? const [];
    final results = byDate
        .cast<Map<String, dynamic>>()
        .map((o) => Asteroid.fromJson(o))
        .toList();
    results.sort((a, b) => a.missDistanceAu.compareTo(b.missDistanceAu));
    return results;
  }

  void dispose() => _client.close();
}
