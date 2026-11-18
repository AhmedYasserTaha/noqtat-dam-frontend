abstract final class FirestorePaths {
  static const users = 'users';
  static const posts = 'posts';
  static String user(String uid) => 'users/$uid';
  static String post(String id) => 'posts/$id';
  static String pledges(String id) => 'posts/$id/pledges';
  static String pledge(String id, String uid) => '${pledges(id)}/$uid';
  static String contact(String id) => 'posts/$id/private/contact';
  static String comments(String id) => 'posts/$id/comments';
  static String likes(String id) => 'posts/$id/likes';
}
