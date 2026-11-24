import '../../../core/network/api_client.dart';
import '../domain/policy_document.dart';

class ContentRemoteDataSource {
  ContentRemoteDataSource(this.api);
  final ApiClient api;

  Future<PolicyDocument> load(String slug) async {
    final j = await api.get('/content/${Uri.encodeComponent(slug)}');
    return PolicyDocument(
      slug: j['slug'] as String,
      title: j['title'] as String,
      isDraft: j['isDraft'] as bool? ?? true,
      notice: j['notice'] as String?,
      sections: [
        for (final s in (j['sections'] as List))
          PolicySection(
            id: (s as Map<String, dynamic>)['id'] as String,
            heading: s['heading'] as String,
            body: s['body'] as String,
          ),
      ],
    );
  }
}
