import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../../core/widgets/preview_ui.dart';
import '../../../../l10n/app_localizations.dart';

class MyRequestsPage extends StatefulWidget {
  const MyRequestsPage({super.key});
  @override
  State<MyRequestsPage> createState() => _MyRequestsPageState();
}

class _MyRequestsPageState extends State<MyRequestsPage> {
  int _tab = 0;
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final statusLabels = [
      t.requestActive,
      t.requestComplete,
      t.requestCancelled,
    ];
    final requests = [
      (
        type: 'O-',
        title: t.threeBagsNeeded,
        hospital: t.demoUniversityHospital,
        date: '20/11/2026',
        collected: 1,
        total: 3,
        status: 0,
      ),
      (
        type: 'B-',
        title: t.twoBagsTitle,
        hospital: t.demoTalkhaHospital,
        date: '18/11/2026',
        collected: 0,
        total: 2,
        status: 0,
      ),
      (
        type: 'A+',
        title: t.plateletsTitle,
        hospital: t.demoSalamHospital,
        date: '12/11/2026',
        collected: 1,
        total: 1,
        status: 1,
      ),
      (
        type: 'O-',
        title: t.twoBagsTitle,
        hospital: t.demoUniversityHospital,
        date: '05/11/2026',
        collected: 0,
        total: 2,
        status: 2,
      ),
    ];
    return PreviewPage(
      title: t.myRequestsTab,
      subtitle: t.staticAccountPreview,
      children: [
        Row(
          children: [
            for (var i = 0; i < 3; i++)
              Expanded(
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(end: 6),
                  child: ChoiceChip(
                    showCheckmark: false,
                    label: Text(
                      statusLabels[i],
                      style: TextStyle(
                        fontSize: 12,
                        color: _tab == i ? Colors.white : AppColors.ink,
                      ),
                    ),
                    selected: _tab == i,
                    selectedColor: AppColors.ink,
                    onSelected: (_) => setState(() => _tab = i),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        for (final request in requests.where((r) => r.status == _tab)) ...[
          PreviewCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: request.status == 0
                            ? AppColors.red
                            : const Color(0xFFF5F0ED),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        request.type,
                        textDirection: TextDirection.ltr,
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 17,
                          color: request.status == 0
                              ? Colors.white
                              : AppColors.ink,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            request.title,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            statusLabels[request.status],
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.red,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const AppIcon(
                      AppIcons.locationPin,
                      color: AppColors.muted,
                      size: 15,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        request.hospital,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.muted,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  '${t.requestDateLabel} ${request.date}',
                  style: const TextStyle(fontSize: 11, color: AppColors.muted),
                ),
                const SizedBox(height: 10),
                LinearProgressIndicator(
                  value: request.collected / request.total,
                  minHeight: 4,
                  borderRadius: BorderRadius.circular(8),
                  backgroundColor: AppColors.border,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${request.collected} / ${request.total} · ${t.bagsCollectedLabel}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.muted,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 36),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        textStyle: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      onPressed: () => showPreviewMessage(
                        context,
                        t.requestDetails,
                        '${request.title}\n${request.hospital}\n${t.demoRequestNotes}\n\n${t.staticAccountPreview}',
                      ),
                      child: Text(t.requestDetails),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
        ElevatedButton(
          onPressed: () => context.push('/blood-request'),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const AppIcon(AppIcons.plus, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(t.createRequestAction),
            ],
          ),
        ),
      ],
    );
  }
}
