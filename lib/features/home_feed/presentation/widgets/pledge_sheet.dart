import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/maps_launcher.dart';
import '../../../../core/utils/request_text.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../blood_request/domain/entities/blood_request.dart';
import '../../../hospitals/presentation/widgets/hospital_map_button.dart';

enum PledgeAction { donated, cancel }

/// `tel:` link for a requester's number as typed. Keeps digits and a leading +.
Uri callUri(String phone) =>
    Uri(scheme: 'tel', path: phone.replaceAll(RegExp(r'[^\d+]'), ''));

/// WhatsApp chat link (wa.me, no message text). Egyptian numbers typed with a
/// leading 0 (01xxxxxxxxx) become 20 1xxxxxxxxx. Null when the number does not
/// look like a phone number.
Uri? whatsappUri(String phone) {
  var d = phone.replaceAll(RegExp(r'[^\d]'), '');
  if (phone.trim().startsWith('00')) d = d.substring(2);
  if (d.startsWith('0') && !phone.trim().startsWith('+'))
    d = '20${d.substring(1)}';
  if (d.length < 10 || d.length > 15) return null;
  return Uri.https('wa.me', '/$d');
}

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
  showDragHandle: true,
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
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  t.pledgeTitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              IconButton(
                tooltip: t.closeLocations,
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.ink.withValues(alpha: 0.08)),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.red.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    request.bloodType,
                    textDirection: TextDirection.ltr,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.red,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.hospitalName,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        placeLine(request, lang),
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                HospitalMapButton(
                  compact: true,
                  location: request.hospitalLocation,
                  searchQuery:
                      '${request.hospitalName} ${placeLine(request, lang)}',
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (phone != null) ...[
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    key: const ValueKey('contact-call'),
                    onPressed: () async {
                      final ok = await getIt<MapsLauncher>().openLink(
                        callUri(phone),
                      );
                      if (!ok && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(t.contactOpenFailed)),
                        );
                      }
                    },
                    icon: const Icon(Icons.call_rounded, size: 18),
                    label: Text(t.callRequester),
                  ),
                ),
                if (whatsappUri(phone) != null) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      key: const ValueKey('contact-whatsapp'),
                      onPressed: () async {
                        final ok = await getIt<MapsLauncher>().openLink(
                          whatsappUri(phone)!,
                        );
                        if (!ok && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(t.contactOpenFailed)),
                          );
                        }
                      },
                      icon: const Icon(Icons.chat_rounded, size: 18),
                      label: Text(t.whatsappRequester),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
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
          ],
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F7F7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              t.pledgeNote,
              style: const TextStyle(
                color: AppColors.muted,
                fontSize: 11,
                height: 1.6,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, PledgeAction.donated),
                  child: Text(t.iDonated),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context, PledgeAction.cancel),
                  child: Text(t.cancelPledge),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
