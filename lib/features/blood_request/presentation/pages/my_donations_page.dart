import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../../../../core/di/injection.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/failure_message.dart';
import '../../../../core/utils/request_text.dart';
import '../../../../core/utils/maps_launcher.dart';
import '../../../home_feed/presentation/widgets/pledge_sheet.dart' show callUri;
import '../../data/datasources/my_donations_api.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/blood_request.dart';

class MyDonationsPage extends StatefulWidget {
  const MyDonationsPage({super.key});
  @override
  State<MyDonationsPage> createState() => _MyDonationsPageState();
}

class _MyDonationsPageState extends State<MyDonationsPage> {
  PledgeStatus? _filter;
  final _api = MyDonationsApi(getIt<ApiClient>());
  List<MyDonation> _items = [];
  String? _next;
  Failure? _failure;
  bool _loading = true;
  bool _loadingMore = false;
  int? _updating;
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool more = false}) async {
    if (more && (_loading || _loadingMore || _next == null)) return;
    final generation = more ? _generation : ++_generation;
    final cursor = more ? _next : null;
    setState(() {
      _failure = null;
      if (more) {
        _loadingMore = true;
      } else {
        _loading = true;
        _loadingMore = false;
        _items = [];
        _next = null;
      }
    });
    try {
      final page = await _api.list(status: _filter, cursor: cursor);
      if (!mounted || generation != _generation) return;
      setState(() {
        _items = {
          for (final item in [..._items, ...page.items]) item.request.id: item,
        }.values.toList();
        _next = page.next;
      });
    } catch (error) {
      if (!mounted || generation != _generation) return;
      setState(
        () => _failure = error is ApiException
            ? error.failure
            : const UnexpectedFailure(),
      );
    } finally {
      if (mounted && generation == _generation) {
        setState(() {
          _loading = false;
          _loadingMore = false;
        });
      }
    }
  }

  void _select(PledgeStatus? status) {
    setState(() => _filter = status);
    _load();
  }

  String _status(AppLocalizations t, PledgeStatus status) => switch (status) {
    PledgeStatus.onTheWay => t.pledgeOnTheWay,
    PledgeStatus.donated => t.donationRecorded,
    PledgeStatus.cancelled => t.donationCancelled,
  };

  Color _color(PledgeStatus status) => switch (status) {
    PledgeStatus.onTheWay => AppColors.red,
    PledgeStatus.donated => const Color(0xFF287447),
    PledgeStatus.cancelled => AppColors.muted,
  };

  Future<void> _details(MyDonation item) async {
    final t = AppLocalizations.of(context)!;
    final action = await showModalBottomSheet<PledgeStatus>(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (sheetContext) => SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    t.requestDetails,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: t.closeLocations,
                  onPressed: () => Navigator.pop(sheetContext),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            Text(
              item.request.hospitalName,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              '${item.request.bloodType} · ${_status(t, item.status)}',
              style: TextStyle(color: _color(item.status), fontSize: 12),
            ),
            const SizedBox(height: 16),
            if (item.contactPhone?.isNotEmpty == true) ...[
              Text(item.contactPhone!, textDirection: TextDirection.ltr),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () async {
                  final opened = await getIt<MapsLauncher>().openLink(
                    callUri(item.contactPhone!),
                  );
                  if (!mounted || opened) return;
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(t.contactOpenFailed)));
                },
                icon: const Icon(Icons.phone_outlined, size: 18),
                label: Text(t.callRequester),
              ),
            ],
            if (item.status == PledgeStatus.onTheWay && !item.closed) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: () =>
                          Navigator.pop(sheetContext, PledgeStatus.donated),
                      child: Text(t.donationRecorded),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () =>
                          Navigator.pop(sheetContext, PledgeStatus.cancelled),
                      child: Text(t.cancelPledge),
                    ),
                  ),
                ],
              ),
            ] else if (item.closed) ...[
              const SizedBox(height: 12),
              Text(
                t.donationClosed,
                style: const TextStyle(fontSize: 12, color: AppColors.muted),
              ),
            ],
          ],
        ),
      ),
    );
    if (!mounted || action == null) return;
    setState(() => _updating = item.request.id);
    try {
      await _api.update(item.request.id, action);
      if (!mounted) return;
      await _load();
    } catch (error) {
      if (!mounted) return;
      final failure = error is ApiException
          ? error.failure
          : const UnexpectedFailure();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(failureMessage(t, failure))));
    } finally {
      if (mounted) setState(() => _updating = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    final items = _items;
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text(t.myDonationsTitle),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 512),
          child: RefreshIndicator(
            onRefresh: () => _load(),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (final filter in <PledgeStatus?>[
                        null,
                        ...PledgeStatus.values,
                      ])
                        Padding(
                          padding: const EdgeInsetsDirectional.only(end: 8),
                          child: ChoiceChip(
                            key: Key(
                              'donations-filter-${filter?.api ?? 'all'}',
                            ),
                            label: Text(
                              filter == null ? t.filterAll : _status(t, filter),
                            ),
                            selected: _filter == filter,
                            showCheckmark: false,
                            selectedColor: AppColors.ink,
                            labelStyle: TextStyle(
                              fontSize: 11,
                              color: _filter == filter
                                  ? Colors.white
                                  : AppColors.muted,
                            ),
                            onSelected: (_) => _select(filter),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                if (_loading)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_failure != null) ...[
                  Text(
                    failureMessage(t, _failure!),
                    textAlign: TextAlign.center,
                  ),
                  TextButton(
                    onPressed: () =>
                        _load(more: _items.isNotEmpty && _next != null),
                    child: Text(t.retry),
                  ),
                ] else if (items.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Column(
                      children: [
                        const AppIcon(
                          AppIcons.bloodDropOutline,
                          size: 36,
                          color: AppColors.muted,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          t.myDonationsEmpty,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.muted,
                          ),
                        ),
                        TextButton(
                          onPressed: () => _select(null),
                          child: Text(t.filterAll),
                        ),
                      ],
                    ),
                  ),
                for (final item in items)
                  Container(
                    key: Key('donation-${item.request.id}'),
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.ink.withValues(alpha: 0.06),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 46,
                              height: 50,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: _color(item.status)
                                    .withValues(alpha: 0.07),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                item.request.bloodType,
                                textDirection: TextDirection.ltr,
                                style: TextStyle(
                                  color: _color(item.status),
                                  fontWeight: FontWeight.w800,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.request.hospitalName,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  if (placeLine(
                                    item.request,
                                    locale.languageCode,
                                  ).trim().isNotEmpty)
                                    Text(
                                      placeLine(
                                        item.request,
                                        locale.languageCode,
                                      ),
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.muted,
                                      ),
                                    ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const AppIcon(
                                        AppIcons.clock,
                                        size: 11,
                                        color: AppColors.muted,
                                      ),
                                      const SizedBox(width: 4),
                                      Flexible(
                                        child: Text(
                                          DateFormat.yMMMd(locale.toString())
                                              .format(item.createdAt.toLocal()),
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: AppColors.muted,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Divider(
                          height: 20,
                          thickness: 0.5,
                          color: Color(0xFFEDEAEA),
                        ),
                        Row(
                          children: [
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 9,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: _color(item.status)
                                      .withValues(alpha: 0.07),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    AppIcon(
                                      item.status == PledgeStatus.donated
                                          ? AppIcons.check
                                          : item.status ==
                                                PledgeStatus.cancelled
                                          ? AppIcons.close
                                          : AppIcons.clock,
                                      size: 12,
                                      color: _color(item.status),
                                    ),
                                    const SizedBox(width: 5),
                                    Flexible(
                                      child: Text(
                                        _status(t, item.status),
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: _color(item.status),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: _updating != null
                                  ? null
                                  : () => _details(item),
                              style: TextButton.styleFrom(
                                minimumSize: const Size(0, 36),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                backgroundColor: AppColors.red.withValues(
                                  alpha: 0.05,
                                ),
                                textStyle: const TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              child: _updating == item.request.id
                                  ? const SizedBox.square(
                                      dimension: 14,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(t.requestDetails),
                                        const SizedBox(width: 4),
                                        const Icon(
                                          Icons.arrow_forward_ios,
                                          size: 11,
                                        ),
                                      ],
                                    ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                if (_loadingMore)
                  const Center(child: CircularProgressIndicator())
                else if (!_loading && _failure == null && _next != null)
                  TextButton(
                    onPressed: () => _load(more: true),
                    child: Text(t.loadMore),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
