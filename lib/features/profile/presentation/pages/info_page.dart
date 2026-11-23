import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';

enum ProfileInfo { privacy, terms, about, help }

class InfoPage extends StatelessWidget {
  const InfoPage({super.key, required this.kind});
  final ProfileInfo kind;
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final (title, sections) = switch (kind) {
      ProfileInfo.privacy => (
        t.privacyTitle,
        [
          (t.privacyDataTitle, t.privacyDataBody),
          (t.privacyContactTitle, t.privacyContactBody),
          (t.privacyControlTitle, t.privacyControlBody),
        ],
      ),
      ProfileInfo.terms => (
        t.termsTitle,
        [
          (t.termsUseTitle, t.termsUseBody),
          (t.termsAccuracyTitle, t.termsAccuracyBody),
          (t.termsMedicalTitle, t.termsMedicalBody),
        ],
      ),
      ProfileInfo.about => (
        t.aboutTitle,
        [(t.authBrand, t.aboutBody), (t.versionLabel, '1.0.0 · UI Preview')],
      ),
      ProfileInfo.help => (
        t.helpTitle,
        [
          (t.helpRequestTitle, t.helpRequestBody),
          (t.helpDonateTitle, t.helpDonateBody),
          (t.helpContactTitle, t.helpContactBody),
        ],
      ),
    };
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
        ),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 512),
          child: ListView(
            padding: const EdgeInsets.all(18),
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F2EF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  kind == ProfileInfo.privacy || kind == ProfileInfo.terms
                      ? t.policyDraftNotice
                      : t.staticAccountPreview,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.8,
                    color: AppColors.muted,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              for (final (heading, body) in sections) ...[
                Text(
                  heading,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  body,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.75,
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
  }
}
