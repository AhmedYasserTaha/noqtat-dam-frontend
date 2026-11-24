import 'package:flutter/material.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/maps_launcher.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/hospital.dart';
import 'osm_credit.dart';

/// Opens the hospital in Google Maps. With a directory [location] it opens the
/// exact coordinates. Without one (old request, name typed by hand) it only
/// offers a search by [searchQuery] and says the result needs checking.
class HospitalMapButton extends StatelessWidget {
  const HospitalMapButton({
    super.key,
    required this.location,
    required this.searchQuery,
    this.showLocationNote = true,
    this.showCredit = true,
  });
  final HospitalLocation? location;
  final String searchQuery;
  final bool showLocationNote;
  final bool showCredit;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final place = location;
    final exact = place != null;
    final note = !exact
        ? t.hospitalTypedByHand
        : place.isVerified
        ? null
        : t.hospitalLocationUnreviewed;
    final label = exact ? t.openHospitalInMaps : t.searchHospitalInMaps;
    final icon = Icon(
      exact ? Icons.directions_rounded : Icons.search_rounded,
      size: 18,
    );
    Future<void> open() async {
      final maps = getIt<MapsLauncher>();
      final ok = exact
          ? await maps.openCoordinates(place.latitude, place.longitude)
          : await maps.search(searchQuery);
      if (ok || !context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(t.mapsOpenFailed)));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        exact
            ? FilledButton.icon(
                key: const ValueKey('hospital-map-button'),
                onPressed: open,
                icon: icon,
                label: Text(label),
              )
            : OutlinedButton.icon(
                key: const ValueKey('hospital-map-button'),
                onPressed: open,
                icon: icon,
                label: Text(label),
              ),
        if (showCredit && place != null && place.creditsOpenStreetMap) ...[
          const SizedBox(height: 6),
          const OsmCredit(),
        ],
        if (showLocationNote && note != null) ...[
          const SizedBox(height: 6),
          Text(
            note,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.muted,
              height: 1.7,
            ),
          ),
        ],
      ],
    );
  }
}
