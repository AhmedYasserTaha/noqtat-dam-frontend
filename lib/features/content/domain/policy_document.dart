class PolicySection {
  const PolicySection({
    required this.id,
    required this.heading,
    required this.body,
  });
  final String id;
  final String heading;
  final String body;
}

/// A content page served by `GET /content/:slug`.
class PolicyDocument {
  const PolicyDocument({
    required this.slug,
    required this.title,
    required this.isDraft,
    required this.notice,
    required this.sections,
  });
  final String slug;
  final String title;

  /// True while the text is a description of the app, not a reviewed policy.
  final bool isDraft;
  final String? notice;
  final List<PolicySection> sections;
}
