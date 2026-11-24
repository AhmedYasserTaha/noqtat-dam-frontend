import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/request_text.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../blood_request/domain/entities/blood_request.dart';
import '../../../hospitals/presentation/widgets/hospital_map_button.dart';

enum PledgeAction { donated, cancel }

/// Shows the requester's phone after a pledge. "I donated" is the donor's own
/// record; nothing here is verified by a hospital.
Future<PledgeAction?> showPledgeSheet(
  BuildContext context,
  BloodRequest request,
) => showModalBottomSheet<PledgeAction>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  backgroundColor: Colors.white,
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
  ),
  builder: (context) => _PledgeSheet(request: request),
);

class _PledgeSheet extends StatelessWidget {
  const _PledgeSheet({required this.request});
  final BloodRequest request;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final lang = Localizations.localeOf(context).languageCode;
    final phone = request.contactPhone;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            t.pledgeTitle,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(
            '${request.hospitalName} · ${placeLine(request, lang)}',
            style: const TextStyle(color: AppColors.muted, fontSize: 13),
          ),
          const SizedBox(height: 14),
          HospitalMapButton(
            location: request.hospitalLocation,
            searchQuery: '${request.hospitalName} ${placeLine(request, lang)}',
          ),
          const SizedBox(height: 12),
          if (phone != null)
            OutlinedButton.icon(
              key: const ValueKey('contact-phone'),
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: phone));
                if (!context.mounted) return;
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(t.phoneCopied)));
              },
              icon: const Icon(Icons.copy_rounded, size: 18),
              label: Text(phone, textDirection: TextDirection.ltr),
            ),
          const SizedBox(height: 12),
          Text(
            t.pledgeNote,
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 12,
              height: 1.8,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, PledgeAction.donated),
            child: Text(t.iDonated),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.pop(context, PledgeAction.cancel),
            child: Text(t.cancelPledge),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(t.closeLocations),
          ),
        ],
      ),
    );
  }
}
