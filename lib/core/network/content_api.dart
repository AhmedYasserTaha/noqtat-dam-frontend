import '../constants/api_constants.dart';
import 'api_client.dart';

class ContentSection {
  const ContentSection(this.heading, this.body);
  final String heading, body;
}

class ContentPage {
  const ContentPage({
    required this.title,
    required this.sections,
    required this.isDraft,
    this.notice,
  });
  final String title;
  final List<ContentSection> sections;
  final bool isDraft;
  final String? notice;
}

class ContentApi {
  const ContentApi(this.api);
  final ApiClient api;
  Future<ContentPage> page(String slug, String language) async {
    final json = await api.get(
      ApiConstants.contentPage(slug),
      query: {'lang': language},
    );
    return ContentPage(
      title: json['title'] as String,
      isDraft: json['isDraft'] as bool? ?? false,
      notice: json['notice'] as String?,
      sections: [
        for (final section in json['sections'] as List)
          ContentSection(
            section['heading'] as String,
            section['body'] as String,
          ),
      ],
    );
  }
}
