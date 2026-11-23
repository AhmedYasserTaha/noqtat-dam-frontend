/// Backend base URL. Override per build:
/// `flutter run --dart-define=API_BASE_URL=https://api.example.com`
///
/// The default targets a backend running on the host machine as seen from the
/// Android emulator. On iOS simulator or a real device pass your own URL.
const apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://10.0.2.2:3000',
);
