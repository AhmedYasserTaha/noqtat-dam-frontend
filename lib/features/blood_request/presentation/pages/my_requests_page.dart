import 'package:flutter/material.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/utils/maps_launcher.dart';
import '../../../home_feed/presentation/widgets/pledge_sheet.dart' show callUri;
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
    Navigator.of(context, rootNavigator: true).push<void>(
      MaterialPageRoute(
        builder: (context) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: cubit),
            BlocProvider(create: (_) => getIt<PledgesCubit>()..load(r.id)),
          ],
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              leading: const BackButton(),
              title: Text(AppLocalizations.of(context)!.requestDetails),
            ),
            body: SafeArea(child: _RequestDetails(request: r)),
          ),
        ),
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
                    if (r.status == RequestStatus.open &&
                        r.selfReportedDonatedCount > 0) ...[
                      Text(
                        t.selfReportedBanner(r.selfReportedDonatedCount),
                        key: Key('self-reported-${r.id}'),
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.red,
                          fontWeight: FontWeight.w700,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                    ],
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

  /// The request as it was when the page opened. The page shows the fresh
  /// copy from the list (after a confirmation, for example).
  final BloodRequest request;

  @override
  Widget build(BuildContext context) {
    final initial = request;
    final fresh = context.select<MyRequestsCubit, BloodRequest>((c) {
      for (final r in c.state.items) {
        if (r.id == initial.id) return r;
      }
      return initial;
    });
    return _buildDetails(context, fresh);
  }

  Widget _buildDetails(BuildContext context, BloodRequest request) {
    final t = AppLocalizations.of(context)!;
    final lang = Localizations.localeOf(context).languageCode;
    final cubit = context.read<MyRequestsCubit>();
    final open = request.status == RequestStatus.open;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _DetailsSection(
            child: Row(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.red,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    request.bloodType,
                    textDirection: TextDirection.ltr,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.bagsNeeded(request.bagsNeeded),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${request.bagsCollected} / ${request.bagsNeeded} · ${t.bagsCollectedLabel}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.muted,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: request.bagsNeeded > 0
                              ? (request.bagsCollected / request.bagsNeeded)
                                    .clamp(0.0, 1.0)
                              : 0,
                          minHeight: 5,
                          color: AppColors.red,
                          backgroundColor: AppColors.red.withValues(
                            alpha: 0.08,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _DetailsSection(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  t.hospitalNameLabel,
                  style: const TextStyle(fontSize: 12, color: AppColors.muted),
                ),
                const SizedBox(height: 6),
                Text(
                  '${request.hospitalName}\n${placeLine(request, lang)}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    height: 1.7,
                  ),
                ),
                const SizedBox(height: 10),
                HospitalMapButton(
                  location: request.hospitalLocation,
                  searchQuery:
                      '${request.hospitalName} ${placeLine(request, lang)}',
                ),
                if ((request.notes ?? '').isNotEmpty) ...[
                  const Divider(height: 24),
                  Text(
                    t.requestNotesLabel,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.muted,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    request.notes!,
                    style: const TextStyle(fontSize: 13, height: 1.6),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          _DetailsSection(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _PledgesList(),
                const Divider(height: 24),
                Text(
                  t.onTheWayCount(request.onTheWayCount),
                  style: const TextStyle(color: AppColors.muted, fontSize: 12),
                ),
                const SizedBox(height: 12),
                if (open && request.selfReportedDonatedCount > 0) ...[
                  Text(
                    t.selfReportedBanner(request.selfReportedDonatedCount),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.red,
                      fontWeight: FontWeight.w700,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                if (open && request.isCovered) ...[
                  Text(
                    t.coveredHint,
                    key: const Key('covered-hint'),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.muted,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ],
            ),
          ),
          if (open) ...[
            const SizedBox(height: 12),
            _DetailsSection(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
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
                              }
                            : null,
                        icon: const AppIcon(
                          AppIcons.plus,
                          color: AppColors.red,
                        ),
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
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailsSection extends StatelessWidget {
  const _DetailsSection({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: AppColors.ink.withValues(alpha: 0.09)),
      borderRadius: BorderRadius.circular(18),
    ),
    child: child,
  );
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
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.status == PledgeStatus.donated
                      ? t.pledgeDonated
                      : p.status == PledgeStatus.onTheWay
                      ? t.pledgeOnTheWay
                      : t.cancelPledge,
                ),
                if (p.donorPhone?.isNotEmpty == true)
                  Wrap(
                    spacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(p.donorPhone!, textDirection: TextDirection.ltr),
                      TextButton.icon(
                        icon: const Icon(Icons.phone_outlined, size: 16),
                        label: Text(t.callRequester),
                        onPressed: () async {
                          final opened = await getIt<MapsLauncher>().openLink(
                            callUri(p.donorPhone!),
                          );
                          if (!context.mounted || opened) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(t.contactOpenFailed)),
                          );
                        },
                      ),
                    ],
                  ),
              ],
            ),
            trailing: Text(p.bloodType, textDirection: TextDirection.ltr),
          ),
      ],
    );
  }
}
