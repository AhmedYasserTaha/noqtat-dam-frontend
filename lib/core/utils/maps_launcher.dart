import 'package:url_launcher/url_launcher.dart';

/// Opens a place in Google Maps. Maps URLs need no API key
/// (https://developers.google.com/maps/documentation/urls/get-started).
/// Behind an interface so tests and widgets never touch the plugin directly.
abstract interface class MapsLauncher {
  /// Opens the exact coordinates. Returns false when nothing could open it.
  Future<bool> openCoordinates(double latitude, double longitude);

  /// Searches Maps for free text. Used only for hospitals typed by hand, whose
  /// position was never reviewed.
  Future<bool> search(String query);
}

Uri mapsCoordinatesUri(double latitude, double longitude) => Uri.https(
  'www.google.com',
  '/maps/search/',
  {'api': '1', 'query': '$latitude,$longitude'},
);

Uri mapsSearchUri(String query) =>
    Uri.https('www.google.com', '/maps/search/', {'api': '1', 'query': query});

class UrlLauncherMapsLauncher implements MapsLauncher {
  const UrlLauncherMapsLauncher();

  @override
  Future<bool> openCoordinates(double latitude, double longitude) =>
      _open(mapsCoordinatesUri(latitude, longitude));

  @override
  Future<bool> search(String query) => _open(mapsSearchUri(query));

  Future<bool> _open(Uri uri) async {
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }
}
