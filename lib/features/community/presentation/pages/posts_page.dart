import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/failure_message.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../home_feed/presentation/widgets/feed_cards.dart';
import '../cubit/posts_cubit.dart';

class PostsPage extends StatelessWidget {
  const PostsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final state = context.watch<PostsCubit>().state;
    final cubit = context.read<PostsCubit>();
    return Scaffold(
      appBar: AppBar(title: Text(t.postsTitle)),
      body: RefreshIndicator(
        onRefresh: () => cubit.load(),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 512),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                for (final post in state.items) ...[
                  CommunityPostCard(post: post),
                  const SizedBox(height: 12),
                ],
                if (state.loading)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (state.failure != null) ...[
                  Text(
                    failureMessage(t, state.failure!),
                    textAlign: TextAlign.center,
                  ),
                  TextButton(
                    onPressed: () => cubit.load(more: state.next != null),
                    child: Text(t.retry),
                  ),
                ] else if (state.next != null)
                  TextButton(
                    onPressed: () => cubit.load(more: true),
                    child: Text(t.loadMore),
                  )
                else if (state.items.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(t.postsEmpty, textAlign: TextAlign.center),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
