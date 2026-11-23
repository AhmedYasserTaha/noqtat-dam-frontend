/// Backend base URL. Override per build:
/// `flutter run --dart-define=API_BASE_URL=https://api.example.com`
///
/// The default targets a USB-connected Android phone using adb reverse.
/// For the Android emulator, override API_BASE_URL with http://10.0.2.2:3000.
const apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://127.0.0.1:3000',
);
