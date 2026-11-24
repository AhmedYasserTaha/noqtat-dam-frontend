import 'dart:math' as math;

import 'package:geolocator/geolocator.dart';

enum LocationOutcome { ok, denied, deniedForever, serviceOff, failed }

class DeviceLocationResult {
  const DeviceLocationResult.ok(this.latitude, this.longitude)
    : outcome = LocationOutcome.ok;
  const DeviceLocationResult.failed(this.outcome)
    : latitude = null,
      longitude = null;
  final LocationOutcome outcome;
  final double? latitude, longitude;
}

/// The phone's position, asked for only when the user taps "closest to me".
/// Used on the device for sorting and never sent to the server or stored.
/// Behind an interface so tests never touch the plugin.
abstract interface class DeviceLocation {
  Future<DeviceLocationResult> current();
}

class GeolocatorDeviceLocation implements DeviceLocation {
  const GeolocatorDeviceLocation();

  @override
  Future<DeviceLocationResult> current() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        return const DeviceLocationResult.failed(LocationOutcome.serviceOff);
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        return const DeviceLocationResult.failed(LocationOutcome.deniedForever);
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.unableToDetermine) {
        return const DeviceLocationResult.failed(LocationOutcome.denied);
      }
      final p = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 12),
        ),
      );
      return DeviceLocationResult.ok(p.latitude, p.longitude);
    } catch (_) {
      return const DeviceLocationResult.failed(LocationOutcome.failed);
    }
  }
}

/// Great-circle distance in kilometres (haversine).
double distanceKm(double lat1, double lon1, double lat2, double lon2) {
  const r = 6371.0088;
  double rad(double d) => d * math.pi / 180;
  final dLat = rad(lat2 - lat1);
  final dLon = rad(lon2 - lon1);
  final a =
      math.pow(math.sin(dLat / 2), 2) +
      math.cos(rad(lat1)) * math.cos(rad(lat2)) * math.pow(math.sin(dLon / 2), 2);
  return 2 * r * math.asin(math.min(1, math.sqrt(a)));
}
