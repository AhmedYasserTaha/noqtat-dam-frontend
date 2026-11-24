import 'package:share_plus/share_plus.dart';

/// Opens the system share sheet (WhatsApp, Messenger, ...). Behind an
/// interface so tests and widgets never touch the plugin directly.
abstract interface class ShareService {
  Future<void> shareText(String text);
}

class SharePlusShareService implements ShareService {
  const SharePlusShareService();
  @override
  Future<void> shareText(String text) async {
    await SharePlus.instance.share(ShareParams(text: text));
  }
}
