/// Backend address and endpoint paths. Query parameters stay with each request.
abstract final class ApiConstants {
  /// Override using --dart-define=API_BASE_URL=https://api.example.com.
  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:3000',
  );

  // Authentication.
  static const register = '/auth/register';
  static const login = '/auth/login';
  static const forgotPassword = '/auth/forgot-password';
  static const resetPassword = '/auth/reset-password';

  // Account and notifications.
  static const profile = '/profile';
  static const changePassword = '/profile/change-password';
  static const fcmToken = '/fcm-token';
  static const donations = '/profile/donations';
  static const notifications = '/notifications';
  static const notificationsRead = '/notifications/read';

  // Locations and hospitals.
  static const governorates = '/locations/governorates';
  static String districts(String governorateId) =>
      '$governorates/${Uri.encodeComponent(governorateId)}/districts';
  static const hospitals = '/hospitals';

  // Home and blood requests.
  static const home = '/home';
  static const requests = '/requests';
  static const myRequests = '/requests/mine';
  static String request(int id) => '$requests/$id';
  static String requestPledge(int id) => '${request(id)}/pledge';
  static String requestPledges(int id) => '${request(id)}/pledges';
  static String requestReport(int id) => '${request(id)}/report';

  // Community posts.
  static const posts = '/posts';
  static String post(int id) => '$posts/$id';
  static String postReaction(int id) => '${post(id)}/reaction';
  static String postReport(int id) => '${post(id)}/report';

  // Public translated metadata and informational content.
  static const labels = '/meta/labels';
  static const messages = '/meta/messages';
  static const content = '/content';
  static String contentPage(String slug) =>
      '$content/${Uri.encodeComponent(slug)}';
}
