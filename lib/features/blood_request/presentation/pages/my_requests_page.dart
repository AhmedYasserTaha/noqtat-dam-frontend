import 'package:flutter/material.dart';

import '../../../../core/di/injection.dart';
import '../cubit/pledges_cubit.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../../../../core/constants/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/failure_message.dart';
import '../../../../core/utils/request_text.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../../core/widgets/preview_ui.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../hospitals/presentation/widgets/hospital_map_button.dart';
import '../../domain/entities/blood_request.dart';
import '../cubit/my_requests_cubit.dart';

class MyRequestsPage extends StatefulWidget {
  const MyRequestsPage({super.key});
  @override
  State<MyRequestsPage> createState() => _MyRequestsPageState();
}

class _MyRequestsPageState extends State<MyRequestsPage> {
  @override
  void initState() {
    super.initState();
    context.read<MyRequestsCubit>().load(RequestTab.all);
  }

  void _details(BuildContext context, BloodRequest r) {
    final cubit = context.read<MyRequestsCubit>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: cubit),
          BlocProvider(create: (_) => getIt<PledgesCubit>()..load(r.id)),
        ],
        child: _RequestDetails(request: r),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final lang = Localizations.localeOf(context).languageCode;
    final locale = Localizations.localeOf(context).toString();
    final statusLabels = [
      t.filterAll,
      t.requestActive,
      t.requestComplete,
      t.requestCancelled,
    ];
    return BlocConsumer<MyRequestsCubit, MyRequestsState>(
      listenWhen: (a, b) =>
          b.actionFailure != null && a.actionFailure != b.actionFailure,
      listener: (context, state) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failureMessage(t, state.actionFailure!))),
      ),
      builder: (context, state) {
        final tab = RequestTab.values.indexOf(state.tab);
        return PreviewPage(
          title: t.myRequestsTab,
          subtitle: t.myRequestsSubtitle,
          children: [
            Row(
              children: [
                for (var i = 0; i < RequestTab.values.length; i++)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsetsDirectional.only(end: 6),
                      child: ChoiceChip(
                        showCheckmark: false,
                        label: Text(
                          statusLabels[i],
                          style: TextStyle(
                            fontSize: 12,
                            color: tab == i ? Colors.white : AppColors.ink,
                          ),
                        ),
                        selected: tab == i,
                        selectedColor: AppColors.ink,
                        onSelected: (_) => context.read<MyRequestsCubit>().load(
                          RequestTab.values[i],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            if (state.status == MyRequestsStatus.loading && state.items.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (state.status == MyRequestsStatus.failure)
              Column(
                children: [
                  Text(failureMessage(t, state.failure!)),
                  TextButton(
                    onPressed: () => context.read<MyRequestsCubit>().load(),
                    child: Text(t.retry),
                  ),
                ],
              )
            else if (state.items.isEmpty)
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  t.noRequestsYet,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.muted, fontSize: 13),
                ),
              ),
            for (final r in state.items) ...[
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
                            color: r.status == RequestStatus.open
                                ? AppColors.red
                                : const Color(0xFFF5F0ED),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            r.bloodType,
                            textDirection: TextDirection.ltr,
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 17,
                              color: r.status == RequestStatus.open
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
                                t.bagsNeeded(r.bagsNeeded),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                urgencyLabel(t, r.urgency),
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
                            '${r.hospitalName} · ${placeLine(r, lang)}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.muted,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${t.requestDateLabel} ${DateFormat.yMMMd(locale).format(r.createdAt.toLocal())}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.muted,
                      ),
                    ),
                    const SizedBox(height: 10),
                    LinearProgressIndicator(
                      value: r.bagsCollected / r.bagsNeeded,
                      minHeight: 4,
                      borderRadius: BorderRadius.circular(8),
                      backgroundColor: AppColors.border,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${r.bagsCollected} / ${r.bagsNeeded} · ${t.bagsCollectedLabel} · ${t.onTheWayCount(r.onTheWayCount)}',
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
                          onPressed: () => _details(context, r),
                          child: Text(t.requestDetails),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
            if (state.status == MyRequestsStatus.ready && !state.hasRequests)
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
      },
    );
  }
}

/// Author controls: adjust bags collected, mark fulfilled, or cancel.
class _RequestDetails extends StatelessWidget {
  const _RequestDetails({required this.request});
  final BloodRequest request;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final lang = Localizations.localeOf(context).languageCode;
    final cubit = context.read<MyRequestsCubit>();
    final open = request.status == RequestStatus.open;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '${request.bloodType} · ${t.bagsNeeded(request.bagsNeeded)}',
            textDirection: TextDirection.ltr,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(
            '${request.hospitalName}\n${placeLine(request, lang)}',
            style: const TextStyle(color: AppColors.muted, height: 1.7),
          ),
          const SizedBox(height: 10),
          HospitalMapButton(
            location: request.hospitalLocation,
            searchQuery: '${request.hospitalName} ${placeLine(request, lang)}',
          ),
          if ((request.notes ?? '').isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(request.notes!),
          ],
          const SizedBox(height: 8),
          Text(
            t.onTheWayCount(request.onTheWayCount),
            style: const TextStyle(color: AppColors.muted, fontSize: 12),
          ),
          const SizedBox(height: 12),
          const _PledgesList(),
          if (open) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    t.bagsCollectedLabel,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                IconButton(
                  tooltip: t.decreaseBags,
                  onPressed: request.bagsCollected > 0
                      ? () {
                          cubit.setBagsCollected(
                            request.id,
                            request.bagsCollected - 1,
                          );
                          Navigator.pop(context);
                        }
                      : null,
                  icon: const Text('−', style: TextStyle(fontSize: 22)),
                ),
                Text(
                  '${request.bagsCollected}',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                IconButton(
                  tooltip: t.increaseBags,
                  onPressed: request.bagsCollected < request.bagsNeeded
                      ? () {
                          cubit.setBagsCollected(
                            request.id,
                            request.bagsCollected + 1,
                          );
                          Navigator.pop(context);
                        }
                      : null,
                  icon: const AppIcon(AppIcons.plus, color: AppColors.red),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                cubit.setStatus(request.id, RequestStatus.fulfilled);
                Navigator.pop(context);
              },
              child: Text(t.markFulfilled),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () {
                cubit.setStatus(request.id, RequestStatus.cancelled);
                Navigator.pop(context);
              },
              child: Text(t.cancelRequest),
            ),
          ],
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(t.closeLocations),
          ),
        ],
      ),
    );
  }
}

/// Who pledged on this request. Statuses are the donors' own statements;
/// nothing here is verified.
class _PledgesList extends StatelessWidget {
  const _PledgesList();
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final s = context.watch<PledgesCubit>().state;
    if (s.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.pledgesTitle,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        if (s.items.isEmpty)
          Text(
            t.pledgesEmpty,
            style: const TextStyle(color: AppColors.muted, fontSize: 12),
          ),
        for (final p in s.items)
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            title: Text(p.donorName),
            subtitle: Text(
              p.status == PledgeStatus.donated
                  ? t.pledgeDonated
                  : p.status == PledgeStatus.onTheWay
                  ? t.pledgeOnTheWay
                  : t.cancelPledge,
            ),
            trailing: Text(p.bloodType, textDirection: TextDirection.ltr),
          ),
      ],
    );
  }
}
