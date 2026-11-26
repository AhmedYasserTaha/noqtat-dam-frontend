import 'package:flutter/material.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/content_api.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/failure_message.dart';
import '../../../../l10n/app_localizations.dart';

enum ProfileInfo { privacy, terms, about, help }

class InfoPage extends StatefulWidget {
  const InfoPage({super.key, required this.kind});
  final ProfileInfo kind;
  @override
  State<InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  Future<ContentPage>? _page;
  String? _language;

  void _load() {
    final slug = widget.kind == ProfileInfo.help ? 'faq' : widget.kind.name;
    _page = ContentApi(getIt<ApiClient>()).page(slug, _language!);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final language = Localizations.localeOf(context).languageCode;
    if (_language != language) {
      _language = language;
      _load();
    }
  }

  @override
  void didUpdateWidget(covariant InfoPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.kind != widget.kind) _load();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final title = switch (widget.kind) {
      ProfileInfo.privacy => t.privacyTitle,
      ProfileInfo.terms => t.termsTitle,
      ProfileInfo.about => t.aboutTitle,
      ProfileInfo.help => t.helpTitle,
    };
    return FutureBuilder<ContentPage>(
      future: _page,
      builder: (context, snapshot) {
        final page = snapshot.connectionState == ConnectionState.done
            ? snapshot.data
            : null;
        return Scaffold(
          appBar: AppBar(
            leading: const BackButton(),
            title: Text(page?.title ?? title),
          ),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 512),
              child: snapshot.connectionState != ConnectionState.done
                  ? const CircularProgressIndicator()
                  : snapshot.hasError
                  ? Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            snapshot.error is ApiException
                                ? failureMessage(
                                    t,
                                    (snapshot.error! as ApiException).failure,
                                  )
                                : t.errGeneric,
                            textAlign: TextAlign.center,
                          ),
                          TextButton(
                            onPressed: () => setState(_load),
                            child: Text(t.retry),
                          ),
                        ],
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        if (page!.notice?.isNotEmpty == true ||
                            page.isDraft) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF7F2EF),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              page.notice?.isNotEmpty == true
                                  ? page.notice!
                                  : t.policyDraftNotice,
                              style: const TextStyle(
                                fontSize: 12,
                                height: 1.7,
                                color: AppColors.muted,
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                        ],
                        for (final section in page.sections) ...[
                          Text(
                            section.heading,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            section.body,
                            style: const TextStyle(
                              fontSize: 13,
                              height: 1.8,
                              color: AppColors.muted,
                            ),
                          ),
                          const SizedBox(height: 18),
                        ],
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }
}
