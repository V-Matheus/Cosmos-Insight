import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

/// Thrown for any failure talking to the NASA APIs (network down, timeout,
/// rate limit, non-200 status, malformed body). Carries a human-readable
/// [message] the screens can show directly in an error state.
class NasaApiException implements Exception {
  const NasaApiException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Thin wrapper over `package:http` that knows the NASA base URL and injects
/// the API key on every request.
///
/// The key defaults to the public `DEMO_KEY` (works with no signup, but has a
/// low rate limit). Override it at build/run time without touching code:
///
/// ```sh
/// flutter run --dart-define=NASA_API_KEY=your_key_here
/// ```
class NasaApiClient {
  NasaApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const String _baseUrl = 'https://api.nasa.gov';
  static const String _apiKey = String.fromEnvironment(
    'NASA_API_KEY',
    defaultValue: 'DEMO_KEY',
  );

  static const Duration _timeout = Duration(seconds: 15);

  /// Performs a GET against `$_baseUrl$path`, merging [query] with the API key,
  /// and returns the decoded JSON object. Throws [NasaApiException] on any
  /// transport, status, or decoding error.
  Future<Map<String, dynamic>> getJson(
    String path, {
    Map<String, String> query = const {},
  }) async {
    final uri = Uri.parse('$_baseUrl$path').replace(
      queryParameters: {...query, 'api_key': _apiKey},
    );

    http.Response response;
    try {
      response = await _client.get(uri).timeout(_timeout);
    } on TimeoutException {
      throw const NasaApiException(
        'The request timed out. Check your connection and try again.',
      );
    } on SocketException {
      throw const NasaApiException(
        'No internet connection. Check your network and try again.',
      );
    } catch (_) {
      throw const NasaApiException('Could not reach the NASA servers.');
    }

    if (response.statusCode == 429) {
      throw const NasaApiException(
        'Rate limit reached for DEMO_KEY. Wait a moment and try again, or '
        'supply your own key via --dart-define=NASA_API_KEY.',
      );
    }
    if (response.statusCode != 200) {
      throw NasaApiException(
        'NASA API request failed (HTTP ${response.statusCode}).',
      );
    }

    try {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw const NasaApiException('Received an unexpected response format.');
    }
  }

  /// Releases the underlying HTTP client. Call from the owner's `dispose`.
  void close() => _client.close();
}
