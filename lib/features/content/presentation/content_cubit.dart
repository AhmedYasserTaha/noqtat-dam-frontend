import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/content_remote_datasource.dart';
import '../domain/policy_document.dart';

/// Holds the server copy of a content page. `null` means "not loaded":
/// the page keeps showing its bundled text (which is also marked as draft).
class ContentCubit extends Cubit<PolicyDocument?> {
  ContentCubit(this._source) : super(null);
  final ContentRemoteDataSource _source;

  Future<void> load(String slug) async {
    try {
      final doc = await _source.load(slug);
      if (!isClosed) emit(doc);
    } catch (_) {
      // Offline or older backend: keep the bundled fallback.
    }
  }
}
