import '../../features/blood_request/domain/entities/blood_request.dart';
import '../../l10n/app_localizations.dart';

String urgencyLabel(AppLocalizations t, Urgency u) => switch (u) {
  Urgency.critical => t.urgencyCritical,
  Urgency.within24h => t.urgencyDay,
  Urgency.scheduled => t.urgencyScheduled,
};

String placeLine(BloodRequest r, String lang) {
  final parts = [
    r.district?.of(lang),
    r.governorate?.of(lang),
  ].whereType<String>().where((e) => e.isNotEmpty);
  return parts.join('، ');
}

String timeLeftLabel(AppLocalizations t, DateTime deadline, DateTime now) {
  final d = deadline.difference(now);
  if (d.isNegative) return t.deadlinePassed;
  if (d.inHours >= 48) return t.daysLeft(d.inDays);
  if (d.inMinutes >= 60) return t.hoursLeft(d.inHours);
  return t.minutesLeft(d.inMinutes.clamp(1, 59));
}

String shareText(AppLocalizations t, BloodRequest r, String lang) =>
    t.shareTextBody(
      r.bagsNeeded,
      r.bloodType,
      r.hospitalName,
      placeLine(r, lang),
    );
