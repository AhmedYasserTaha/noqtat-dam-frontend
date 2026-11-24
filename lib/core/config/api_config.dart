// Backend base URL. Override per build:
// `flutter run --dart-define=API_BASE_URL=https://api.example.com`
//
// The default targets a USB-connected Android phone using adb reverse.
// For the Android emulator, override API_BASE_URL with http://10.0.2.2:3000.
import '../constants/api_constants.dart';

// Compatibility alias; the address is defined with the other API constants.
const apiBaseUrl = ApiConstants.baseUrl;
