import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/failure_message.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../home_feed/presentation/cubit/feed_cubit.dart';
import '../cubit/create_post_cubit.dart';

class NewPostPage extends StatefulWidget {
  const NewPostPage({super.key});
  @override
  State<NewPostPage> createState() => _NewPostPageState();
}

class _NewPostPageState extends State<NewPostPage> {
  final _text = TextEditingController();
  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  void _snack(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return BlocConsumer<CreatePostCubit, CreatePostState>(
      listener: (context, state) {
        if (state.status == CreateStatus.success) {
          context.read<FeedCubit>().load();
          _snack(t.postPublished);
          context.go('/');
        } else if (state.status == CreateStatus.failure) {
          _snack(failureMessage(t, state.failure!));
        }
      },
      builder: (context, state) {
        final busy = state.status == CreateStatus.submitting;
        return Scaffold(
          appBar: AppBar(title: Text(t.newPostTitle)),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 512),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  TextField(
                    key: const Key('new-post-field'),
                    controller: _text,
                    minLines: 5,
                    maxLines: 10,
                    maxLength: 1000,
                    decoration: InputDecoration(hintText: t.newPostField),
                  ),
                  Text(
                    t.newPostWarning,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.muted,
                    ),
                  ),
                  const SizedBox(height: 16),
                  PrimaryButton(
                    label: t.newPostPublish,
                    onPressed: busy
                        ? null
                        : () {
                            if (_text.text.trim().isEmpty) {
                              _snack(t.newPostEmpty);
                              return;
                            }
                            context.read<CreatePostCubit>().submit(_text.text);
                          },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
