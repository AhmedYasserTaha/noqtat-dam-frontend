# Flutter API Checker — Current Implementation

This guide reproduces the current API Checker exactly, including the simple response layout. The complete source below is copied from this project.

## 1. Appearance and behavior

- A movable bug button opens the Alice inspector.
- The response body starts collapsed inside one outer card.
- The header contains an expand/collapse arrow, `Response body`, and a copy button.
- Opening the body reveals search, a scrollable viewer, and a resize handle.
- JSON objects and arrays start collapsed and use arrows and indentation, without nested cards.
- Each JSON branch can be opened independently.
- Searching expands branches temporarily, highlights literal case-insensitive matches, and shows a match count.
- Clearing search restores the branch expansion choices.
- Plain text remains selectable and supports horizontal scrolling.
- Copy always copies the full formatted response, including collapsed content.
- Large text responses retain Alice's `Show body` safeguard before displaying the response card.

```text
Collapsed:
┌───────────────────────────────────────────┐
│  ˅  Response body                    Copy │
└───────────────────────────────────────────┘

Expanded:
┌───────────────────────────────────────────┐
│  ˄  Response body                    Copy │
│  Search response          0 matches    ×  │
│                                           │
│  ▸ { 2 items }                            │
│                                           │
│                    ═                      │
└───────────────────────────────────────────┘

Opened JSON branches use indentation only:
▾ {
    ▾ "data": {
        "name": "Ahmed"
    }
}
```

## 2. Dependencies and local Alice package

Keep the project's existing dependency versions:

```yaml
dependencies:
  alice: ^1.0.0
  alice_dio: ^1.0.7
  dio: ^5.4.0

dependency_overrides:
  alice:
    path: third_party/alice
```

`third_party/alice` contains a local copy of Alice 1.0.0 because its response UI is customized. When moving this implementation to another project, copy that entire folder, including `lib/`, `pubspec.yaml`, and `LICENSE`. Do not edit the global Pub cache.

For a fresh local copy, take Alice 1.0.0's `lib/`, `pubspec.yaml`, and `LICENSE`, then replace/add the two response files provided below at their exact paths. The response screen preserves Alice's headers, status, image/video handling, and large-body safeguard.

Run `flutter pub get` after adding the override.

## 3. Initialization and application integration

Initialize the checker before creating or resolving the Dio singleton. Use the same navigator key as your app:

```dart
final appNavigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ApiChecker.init(
    environment: AppEnvironment.dev,
    navigatorKey: appNavigatorKey,
  );
  // Set up dependencies and create Dio after initialization.
  runApp(const MyApp());
}
```

Attach once after configuring the other Dio interceptors:

```dart
ApiChecker.attachToDio(dio);
```

Wire the navigator and overlay into your existing app:

```dart
MaterialApp(
  navigatorKey: appNavigatorKey,
  builder: (context, child) => ApiCheckerWidget(
    isActive: ApiChecker.isActive,
    onPressed: ApiChecker.openInspector,
    child: child ?? const SizedBox.shrink(),
  ),
);
```

Preserve any existing app builder wrappers. The `environment` argument is retained for compatibility; it does not automatically disable production inspection. Set `ApiChecker.isEnabled` or pass `enableInspector` before initialization to control availability. Initialization is idempotent, and attaching the adapter repeatedly does not duplicate it.

## 4. Exact source files

Copy each complete code block to the indicated path. These are the actual files used for the current appearance.

### `lib/core/network/api_checker.dart`

```dart
import 'package:flutter/material.dart';
import 'package:alice/alice.dart';
import 'package:alice/model/alice_configuration.dart';
import 'package:alice_dio/alice_dio_adapter.dart';
import 'package:dio/dio.dart';

enum AppEnvironment { dev, staging, prod }

class ApiChecker {
  static bool isEnabled = true;

  static final _fallbackNavigatorKey = GlobalKey<NavigatorState>();
  static Alice? _alice;
  static AliceDioAdapter? _adapter;

  static void init({
    required AppEnvironment environment,
    GlobalKey<NavigatorState>? navigatorKey,
    bool? enableInspector,
  }) {
    if (!(enableInspector ?? isEnabled) || _alice != null) return;

    _alice = Alice(
      configuration: AliceConfiguration(
        showNotification: false,
        directionality: TextDirection.ltr,
      ),
    );
    if (navigatorKey != null) {
      _alice!.setNavigatorKey(navigatorKey);
    }
    _adapter = AliceDioAdapter();
    _alice!.addAdapter(_adapter!);
  }

  static void attachToDio(Dio dio) {
    if (_adapter != null && !dio.interceptors.contains(_adapter)) {
      dio.interceptors.add(_adapter!);
    }
  }

  static GlobalKey<NavigatorState>? navigatorKey() =>
      _alice?.getNavigatorKey() ?? _fallbackNavigatorKey;

  static void openInspector() => _alice?.showInspector();
  static void openAlice() => openInspector();

  static isDevMode() => _alice != null;

  static bool get isActive => _alice != null;
}
```


### `lib/core/widget/api_checker_widget.dart`

```dart
import 'package:flutter/material.dart';

class ApiCheckerWidget extends StatefulWidget {
  final Widget child;
  final bool isActive;
  final VoidCallback onPressed;

  const ApiCheckerWidget({
    super.key,
    required this.child,
    required this.isActive,
    required this.onPressed,
  });

  @override
  State<ApiCheckerWidget> createState() => _ApiCheckerWidgetState();
}

class _ApiCheckerWidgetState extends State<ApiCheckerWidget> {
  double posX = 0;
  double posY = 100;

  @override
  Widget build(BuildContext context) {
    if (!widget.isActive) return widget.child;

    return LayoutBuilder(
      builder: (context, constraints) {
        const buttonSize = 56.0;
        final maxX = (constraints.maxWidth - buttonSize).clamp(
          0.0,
          double.infinity,
        );
        final maxY = (constraints.maxHeight - buttonSize).clamp(
          0.0,
          double.infinity,
        );

        return Stack(
          children: [
            widget.child,
            Positioned(
              left: posX.clamp(0.0, maxX),
              top: posY.clamp(0.0, maxY),
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    posY += details.delta.dy;
                    posY = posY.clamp(0.0, maxY);
                    posX = (posX + details.delta.dx).clamp(0.0, maxX);
                  });
                },
                onPanEnd: (_) {
                  setState(() {
                    final middle = constraints.maxWidth / 2;
                    if (posX < middle) {
                      posX = 0;
                    } else {
                      posX = maxX;
                    }
                  });
                },
                child: IconButton.outlined(
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.8),
                    side: const BorderSide(color: Colors.red),
                  ),
                  onPressed: widget.onPressed,
                  icon: const Icon(
                    Icons.bug_report,
                    color: Colors.red,
                    size: 35,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
```


### `third_party/alice/lib/ui/call_details/widget/alice_call_response_screen.dart`

```dart
import 'alice_response_body.dart';
import 'package:alice/helper/alice_conversion_helper.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:alice/model/alice_translation.dart';
import 'package:alice/ui/call_details/widget/alice_call_list_row.dart';
import 'package:alice/ui/common/alice_context_ext.dart';
import 'package:alice/utils/alice_parser.dart';
import 'package:alice/ui/common/alice_scroll_behavior.dart';
import 'package:alice/utils/num_comparison.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Screen which displays information about HTTP call response.
class AliceCallResponseScreen extends StatelessWidget {
  const AliceCallResponseScreen({super.key, required this.call});

  final AliceHttpCall call;

  @override
  Widget build(BuildContext context) {
    if (!call.loading) {
      return Container(
        padding: const EdgeInsets.all(6),
        child: ScrollConfiguration(
          behavior: AliceScrollBehavior(),
          child: ListView(
            children: [
              _GeneralDataColumn(call: call),
              _HeaderDataColumn(call: call),
              _BodyDataColumn(call: call),
            ],
          ),
        ),
      );
    } else {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [CircularProgressIndicator(), Text('Awaiting response...')],
        ),
      );
    }
  }
}

/// Column which displays general information like received time and bytes
/// count.
class _GeneralDataColumn extends StatelessWidget {
  final AliceHttpCall call;

  const _GeneralDataColumn({required this.call});

  @override
  Widget build(BuildContext context) {
    final int? status = call.response?.status;
    final String statusText =
        status == -1
            ? context.i18n(AliceTranslationKey.callResponseError)
            : '$status';

    return Column(
      children: [
        AliceCallListRow(
          name: context.i18n(AliceTranslationKey.callResponseReceived),
          value: call.response?.time.toString(),
        ),
        AliceCallListRow(
          name: context.i18n(AliceTranslationKey.callResponseBytesReceived),
          value: AliceConversionHelper.formatBytes(call.response?.size ?? 0),
        ),
        AliceCallListRow(
          name: context.i18n(AliceTranslationKey.callResponseStatus),
          value: statusText,
        ),
      ],
    );
  }
}

/// Widget which renders column with headers of [call].
class _HeaderDataColumn extends StatelessWidget {
  final AliceHttpCall call;

  const _HeaderDataColumn({required this.call});

  @override
  Widget build(BuildContext context) {
    final Map<String, String>? headers = call.response?.headers;
    final String headersContent =
        headers?.isEmpty ?? true
            ? context.i18n(AliceTranslationKey.callResponseHeadersEmpty)
            : '';

    return Column(
      children: [
        AliceCallListRow(
          name: context.i18n(AliceTranslationKey.callResponseHeaders),
          value: headersContent,
        ),
        for (final MapEntry<String, String> header in headers?.entries ?? [])
          AliceCallListRow(
            name: '   • ${header.key}:',
            value: header.value.toString(),
          ),
      ],
    );
  }
}

/// Widget which renders column with body of [call].
class _BodyDataColumn extends StatefulWidget {
  const _BodyDataColumn({required this.call});

  final AliceHttpCall call;

  @override
  State<_BodyDataColumn> createState() => _BodyDataColumnState();
}

class _BodyDataColumnState extends State<_BodyDataColumn> {
  static const String _imageContentType = 'image';
  static const String _videoContentType = 'video';
  static const String _jsonContentType = 'json';
  static const String _xmlContentType = 'xml';
  static const String _textContentType = 'text';

  static const int _largeOutputSize = 100000;
  bool _showLargeBody = false;
  bool _showUnsupportedBody = false;

  AliceHttpCall get call => widget.call;

  @override
  Widget build(BuildContext context) {
    if (_isImageResponse()) {
      return _ImageBody(call: call);
    } else if (_isVideoResponse()) {
      return _VideoBody(call: call);
    } else if (_isTextResponse()) {
      if (_isLargeResponseBody()) {
        return _LargeTextBody(
          showLargeBody: _showLargeBody,
          call: call,
          onShowLargeBodyPressed: onShowLargeBodyPressed,
        );
      } else {
        return _TextBody(call: call);
      }
    } else {
      return _UnknownBody(
        call: call,
        showUnsupportedBody: _showUnsupportedBody,
        onShowUnsupportedBodyPressed: onShowUnsupportedBodyPressed,
      );
    }
  }

  /// Checks whether content type of response is image.
  bool _isImageResponse() {
    return _getContentTypeOfResponse()!.toLowerCase().contains(
      _imageContentType,
    );
  }

  /// Checks whether content type of response is video
  bool _isVideoResponse() {
    return _getContentTypeOfResponse()!.toLowerCase().contains(
      _videoContentType,
    );
  }

  /// Checks whether content type of response is text.
  bool _isTextResponse() {
    final responseContentTypeLowerCase =
        _getContentTypeOfResponse()!.toLowerCase();

    return responseContentTypeLowerCase.contains(_jsonContentType) ||
        responseContentTypeLowerCase.contains(_xmlContentType) ||
        responseContentTypeLowerCase.contains(_textContentType);
  }

  /// Parses headers and returns content type of response. It may return null.
  String? _getContentTypeOfResponse() {
    return AliceParser.getContentType(
      context: context,
      headers: call.response?.headers,
    );
  }

  /// Checks whether response body is large (more than [_largeOutputSize].
  bool _isLargeResponseBody() =>
      call.response?.body.toString().length.gt(_largeOutputSize) ?? false;

  /// Called when show large body has been pressed.
  void onShowLargeBodyPressed() {
    setState(() {
      _showLargeBody = true;
    });
  }

  /// Called when show unsupported body has been pressed.
  void onShowUnsupportedBodyPressed() {
    setState(() {
      _showUnsupportedBody = true;
    });
  }
}

/// Widget which renders body as image.
class _ImageBody extends StatelessWidget {
  const _ImageBody({required this.call});

  final AliceHttpCall call;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              context.i18n(AliceTranslationKey.callResponseBodyImage),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Image.network(
          call.uri,
          fit: BoxFit.fill,
          headers: _buildRequestHeaders(),
          loadingBuilder: (
            BuildContext context,
            Widget child,
            ImageChunkEvent? loadingProgress,
          ) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value:
                    loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
              ),
            );
          },
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  /// Builds request headers to access the image.
  Map<String, String> _buildRequestHeaders() {
    final requestHeaders = <String, String>{};
    if (call.request?.headers != null) {
      requestHeaders.addAll(
        call.request!.headers.map(
          (String key, dynamic value) => MapEntry(key, value.toString()),
        ),
      );
    }
    return requestHeaders;
  }
}

/// Widget which renders large body as a text.
class _LargeTextBody extends StatelessWidget {
  const _LargeTextBody({
    required this.showLargeBody,
    required this.call,
    required this.onShowLargeBodyPressed,
  });

  final bool showLargeBody;
  final AliceHttpCall call;
  final void Function() onShowLargeBodyPressed;

  @override
  Widget build(BuildContext context) {
    if (showLargeBody) {
      return _TextBody(call: call);
    } else {
      return Column(
        children: [
          AliceCallListRow(
            name: context.i18n(AliceTranslationKey.callResponseBody),
            value:
                '${context.i18n(AliceTranslationKey.callResponseTooLargeToShow)}'
                '(${call.response?.body.toString().length ?? 0} B)',
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: onShowLargeBodyPressed,
            child: Text(context.i18n(AliceTranslationKey.callResponseBodyShow)),
          ),
          Text(
            context.i18n(AliceTranslationKey.callResponseLargeBodyShowWarning),
          ),
        ],
      );
    }
  }
}

/// Widget which renders body as a text.
class _TextBody extends StatelessWidget {
  const _TextBody({required this.call});

  final AliceHttpCall call;

  @override
  Widget build(BuildContext context) {
    final Map<String, String>? headers = call.response?.headers;
    final String bodyContent = AliceParser.formatBody(
      context: context,
      body: call.response?.body,
      contentType: AliceParser.getContentType(
        context: context,
        headers: headers,
      ),
    );
    return AliceResponseBody(
      body: call.response?.body,
      formattedBody: bodyContent,
    );
  }
}

/// Widget which renders body as video.
class _VideoBody extends StatelessWidget {
  const _VideoBody({required this.call});

  final AliceHttpCall call;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              context.i18n(AliceTranslationKey.callResponseBodyVideo),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextButton(
          child: Text(
            context.i18n(AliceTranslationKey.callResponseBodyVideoWebBrowser),
          ),
          onPressed: () async {
            await launchUrl(Uri.parse(call.uri));
          },
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

/// Widget which renders unknown body message.
class _UnknownBody extends StatelessWidget {
  static const _contentType = "[contentType]";

  const _UnknownBody({
    required this.call,
    required this.showUnsupportedBody,
    required this.onShowUnsupportedBodyPressed,
  });

  final AliceHttpCall call;
  final bool showUnsupportedBody;
  final void Function() onShowUnsupportedBodyPressed;

  @override
  Widget build(BuildContext context) {
    final Map<String, String>? headers = call.response?.headers;
    final String contentType =
        AliceParser.getContentType(context: context, headers: headers) ??
        context.i18n(AliceTranslationKey.callResponseHeadersUnknown);

    if (showUnsupportedBody) {
      return _TextBody(call: call);
    } else {
      return Column(
        children: [
          AliceCallListRow(
            name: context.i18n(AliceTranslationKey.callResponseBody),
            value: context
                .i18n(AliceTranslationKey.callResponseBodyUnknown)
                .replaceAll(_contentType, contentType),
          ),
          TextButton(
            onPressed: onShowUnsupportedBodyPressed,
            child: Text(
              context.i18n(AliceTranslationKey.callResponseBodyUnknownShow),
            ),
          ),
        ],
      );
    }
  }
}
```


### `third_party/alice/lib/ui/call_details/widget/alice_response_body.dart`

```dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Searchable response viewer shared by text and explicitly revealed bodies.
class AliceResponseBody extends StatefulWidget {
  const AliceResponseBody({
    super.key,
    required this.body,
    required this.formattedBody,
  });
  final dynamic body;
  final String formattedBody;

  @override
  State<AliceResponseBody> createState() => _AliceResponseBodyState();
}

class _AliceResponseBodyState extends State<AliceResponseBody> {
  final _search = TextEditingController();
  final _vertical = ScrollController();
  final _horizontal = ScrollController();
  dynamic _json;
  late String _text;
  String _query = '';
  int _matches = 0;
  double _height = 550;
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    _prepare();
  }

  @override
  void didUpdateWidget(covariant AliceResponseBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.body != widget.body ||
        oldWidget.formattedBody != widget.formattedBody) {
      _prepare();
    }
  }

  void _prepare() {
    _json = widget.body;
    if (_json is String) {
      try {
        _json = jsonDecode(_json as String);
      } catch (_) {
        _json = null;
      }
    }
    if (_json is! Map && _json is! List) _json = null;
    _text =
        _json == null
            ? widget.formattedBody
            : const JsonEncoder.withIndent('  ').convert(_json);
    _count();
  }

  void _count() {
    _matches =
        _query.isEmpty
            ? 0
            : RegExp(
              RegExp.escape(_query),
              caseSensitive: false,
            ).allMatches(_text).length;
  }

  @override
  void dispose() {
    _search.dispose();
    _vertical.dispose();
    _horizontal.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final maximum = (MediaQuery.sizeOf(context).height * .85).clamp(
      140.0,
      double.infinity,
    );
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              IconButton(
                tooltip: _expanded ? 'Collapse body' : 'Expand body',
                onPressed: () => setState(() => _expanded = !_expanded),
                icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
              ),
              const Expanded(child: Text('Response body')),
              IconButton(
                tooltip: 'Copy full response',
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: _text));
                  if (context.mounted) {
                    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
                      const SnackBar(content: Text('Response copied')),
                    );
                  }
                },
                icon: const Icon(Icons.copy),
              ),
            ],
          ),
          if (_expanded) ...[
            Padding(
              padding: const EdgeInsets.all(8),
              child: TextField(
                controller: _search,
                decoration: InputDecoration(
                  labelText: 'Search response',
                  prefixIcon: const Icon(Icons.search),
                  suffixText: '$_matches matches',
                  suffixIcon: IconButton(
                    tooltip: 'Clear search',
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _search.clear();
                      setState(() {
                        _query = '';
                        _count();
                      });
                    },
                  ),
                ),
                onChanged:
                    (value) => setState(() {
                      _query = value;
                      _count();
                    }),
              ),
            ),
            SizedBox(
              height: _height.clamp(140.0, maximum),
              child: Scrollbar(
                controller: _vertical,
                child: SingleChildScrollView(
                  controller: _vertical,
                  child: Scrollbar(
                    controller: _horizontal,
                    notificationPredicate:
                        (notification) =>
                            notification.metrics.axis == Axis.horizontal,
                    child: SingleChildScrollView(
                      controller: _horizontal,
                      scrollDirection: Axis.horizontal,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child:
                            _json == null
                                ? _highlight(_text, _query)
                                : _JsonNode(
                                  key: ObjectKey(_json),
                                  label: null,
                                  value: _json,
                                  query: _query,
                                ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onVerticalDragUpdate:
                  (details) => setState(
                    () =>
                        _height = (_height.clamp(140.0, maximum) +
                                details.delta.dy)
                            .clamp(140.0, maximum),
                  ),
              child: const SizedBox(
                height: 32,
                child: Center(child: Icon(Icons.drag_handle)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

Widget _highlight(String text, String query) {
  final spans = <TextSpan>[];
  var offset = 0;
  if (query.isNotEmpty) {
    for (final match in RegExp(
      RegExp.escape(query),
      caseSensitive: false,
    ).allMatches(text)) {
      if (match.start > offset) {
        spans.add(TextSpan(text: text.substring(offset, match.start)));
      }
      spans.add(
        TextSpan(
          text: text.substring(match.start, match.end),
          style: const TextStyle(
            backgroundColor: Colors.amber,
            color: Colors.black,
          ),
        ),
      );
      offset = match.end;
    }
  }
  spans.add(TextSpan(text: text.substring(offset)));
  return SelectableText.rich(
    TextSpan(
      style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
      children: spans,
    ),
  );
}

class _JsonNode extends StatefulWidget {
  const _JsonNode({
    super.key,
    required this.label,
    required this.value,
    required this.query,
  });
  final String? label;
  final dynamic value;
  final String query;
  @override
  State<_JsonNode> createState() => _JsonNodeState();
}

class _JsonNodeState extends State<_JsonNode> {
  bool _expanded = false;
  @override
  Widget build(BuildContext context) {
    final value = widget.value;
    final prefix = widget.label == null ? '' : '${widget.label}: ';
    if (value is! Map && value is! List) {
      return _highlight('$prefix${jsonEncode(value)}', widget.query);
    }
    final isMap = value is Map;
    final entries =
        isMap
            ? value.entries
                .map(
                  (entry) =>
                      MapEntry(jsonEncode(entry.key.toString()), entry.value),
                )
                .toList()
            : (value as List)
                .asMap()
                .entries
                .map((entry) => MapEntry(entry.key.toString(), entry.value))
                .toList();
    final open = _expanded || widget.query.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: open ? 'Collapse node' : 'Expand node',
              visualDensity: VisualDensity.compact,
              onPressed:
                  widget.query.isNotEmpty
                      ? null
                      : () => setState(() => _expanded = !_expanded),
              icon: Icon(open ? Icons.arrow_drop_down : Icons.arrow_right),
            ),
            _highlight(
              '$prefix${isMap ? '{' : '['}${open ? '' : ' ${entries.length} items ${isMap ? '}' : ']'}'}',
              widget.query,
            ),
          ],
        ),
        if (open) ...[
          Padding(
            padding: const EdgeInsets.only(left: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final entry in entries)
                  _JsonNode(
                    key: ValueKey(entry.key),
                    label: entry.key,
                    value: entry.value,
                    query: widget.query,
                  ),
              ],
            ),
          ),
          _highlight(isMap ? '}' : ']', widget.query),
        ],
      ],
    );
  }
}
```

## 5. Verification

```bash
flutter pub get
flutter test --no-pub test/core/api_checker_response_test.dart
```

The test command applies when copying the project's existing response test too.

Manual checks:

1. Send a request through the configured Dio instance and open its Response tab.
2. Confirm the response card starts collapsed.
3. Expand the card: search and the collapsed JSON root should appear.
4. Open the JSON root and individual branches. Confirm there are no nested cards.
5. Search for a nested value. Confirm branches expand, matches highlight, and the count updates.
6. Search for punctuation such as `a.b`; it must be treated literally.
7. Clear the query and confirm branches return to their previous expansion choices.
8. Copy while the card is collapsed and verify the entire response is copied.
9. Resize the open body using its bottom handle and check both scroll directions.
10. Test a large response through Alice's `Show body` action.

Stop and restart the app after changing the local Alice package. Hot reload may retain old package code.