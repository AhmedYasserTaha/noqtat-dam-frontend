import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../blood_request/presentation/cubit/blood_request_cubit.dart';
import '../../../blood_request/presentation/pages/blood_request_page.dart';
import '../cubit/create_post_cubit.dart';
import 'new_post_page.dart';

/// The create screen: opens straight on a form, with top tabs to switch
/// between a normal post and a blood request. Each tab keeps what was typed.
class CreateHubPage extends StatelessWidget {
  const CreateHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<CreatePostCubit>()),
        BlocProvider(create: (_) => getIt<BloodRequestCubit>()),
      ],
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              tooltip: MaterialLocalizations.of(context).backButtonTooltip,
              onPressed: () =>
                  context.canPop() ? context.pop() : context.go('/'),
              icon: const AppIcon(AppIcons.arrowBackRtl, color: AppColors.ink),
            ),
            title: Text(
              t.createChoiceTitle,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
            ),
            bottom: TabBar(
              indicatorColor: AppColors.red,
              labelColor: AppColors.red,
              unselectedLabelColor: AppColors.muted,
              labelStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
              tabs: [
                Tab(
                  key: const Key('create-tab-post'),
                  text: t.createPostOption,
                ),
                Tab(
                  key: const Key('create-tab-request'),
                  text: t.createRequestOption,
                ),
              ],
            ),
          ),
          body: const TabBarView(
            children: [
              _KeepAlive(child: NewPostPage(embedded: true)),
              _KeepAlive(child: BloodRequestPage(embedded: true)),
            ],
          ),
        ),
      ),
    );
  }
}

class _KeepAlive extends StatefulWidget {
  const _KeepAlive({required this.child});
  final Widget child;
  @override
  State<_KeepAlive> createState() => _KeepAliveState();
}

class _KeepAliveState extends State<_KeepAlive>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
