import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/maps_launcher.dart';
import '../../../../l10n/app_localizations.dart';

/// OpenStreetMap credit required by the ODbL. "OpenStreetMap" is a link to
/// openstreetmap.org/copyright, which has the source and licence details
/// (https://osmfoundation.org/wiki/Licence/Attribution_Guidelines).
class OsmCredit extends StatefulWidget {
  const OsmCredit({super.key});

  @override
  State<OsmCredit> createState() => _OsmCreditState();
}

class _OsmCreditState extends State<OsmCredit> {
  late final TapGestureRecognizer _tap = TapGestureRecognizer()
    ..onTap = () => getIt<MapsLauncher>().openLink(osmCopyrightUri);

  @override
  void dispose() {
    _tap.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const marker = '\u0001';
    final parts = AppLocalizations.of(context)!
        .hospitalDataCredit(marker)
        .split(marker);
    const base = TextStyle(fontSize: 11, color: AppColors.muted, height: 1.7);
    return Text.rich(
      key: const ValueKey('osm-credit'),
      TextSpan(
        style: base,
        children: [
          TextSpan(text: parts.first),
          TextSpan(
            text: 'OpenStreetMap',
            recognizer: _tap,
            style: const TextStyle(
              color: AppColors.red,
              decoration: TextDecoration.underline,
            ),
          ),
          TextSpan(text: parts.length > 1 ? parts[1] : ''),
        ],
      ),
    );
  }
}
