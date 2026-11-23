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
  bool _expanded = true;
  PageStorageBucket? _storage;
  bool _restored = false;
  Map<String, bool> _branches = {'': true, '/data': true};
  late String _storageId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_restored) return;
    _restored = true;
    _storage = PageStorage.maybeOf(context);
    final keys = <String>['alice-response-view'];
    if (widget.key is PageStorageKey) keys.add(widget.key.toString());
    context.visitAncestorElements((element) {
      if (element.widget.key is PageStorageKey)
        keys.add(element.widget.key.toString());
      return element.widget is! PageStorage;
    });
    _storageId = keys.join('/');
    final saved = _storage?.readState(context, identifier: _storageId);
    if (saved is Map<String, dynamic>) {
      _expanded = true;
      _height = saved['height'] as double;
      _query = saved['query'] as String;
      _search.text = _query;
      _branches = {
        ...Map<String, bool>.from(saved['branches'] as Map),
        '': true,
        '/data': true,
      };
      _count();
    }
  }

  void _save() {
    _storage?.writeState(context, {
      'expanded': _expanded,
      'height': _height,
      'query': _query,
      'branches': _branches,
    }, identifier: _storageId);
  }

  @override
  void deactivate() {
    _save();
    super.deactivate();
  }

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
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.black),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onVerticalDragUpdate:
                (details) => setState(() {
                  _height = (_height.clamp(140.0, maximum) + details.delta.dy)
                      .clamp(140.0, maximum);
                }),
            child: SizedBox(
              height: 18,
              child: Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
          Row(
            children: [
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Body:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
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
              IconButton(
                tooltip: _expanded ? 'Collapse body' : 'Expand body',
                onPressed: () => setState(() => _expanded = !_expanded),
                icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
              ),
            ],
          ),
          if (_expanded) ...[
            Padding(
              padding: const EdgeInsets.all(8),
              child: TextField(
                controller: _search,
                decoration: InputDecoration(
                  hintText: 'Search in response',
                  border: const OutlineInputBorder(),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  prefixIcon: const Icon(Icons.search),
                  suffixText: _query.isEmpty ? null : '$_matches matches',
                  suffixIcon:
                      _query.isEmpty
                          ? null
                          : IconButton(
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
            const Divider(height: 1, color: Colors.black),
            SizedBox(
              height: _height.clamp(140.0, maximum),
              child: LayoutBuilder(
                builder:
                    (context, constraints) => Scrollbar(
                      thumbVisibility: true,
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
                                      : SizedBox(
                                        width: constraints.maxWidth - 24,
                                        child: _JsonNode(
                                          key: ObjectKey(_json),
                                          label: null,
                                          value: _json,
                                          query: _query,
                                          branches: _branches,
                                          path: '',
                                        ),
                                      ),
                            ),
                          ),
                        ),
                      ),
                    ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

Widget _highlight(String text, String query, {int labelLength = 0}) {
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
  final styledSpans = <TextSpan>[];
  var position = 0;
  for (final span in spans) {
    final content = span.text ?? '';
    final boldLength = (labelLength - position).clamp(0, content.length);
    if (boldLength > 0) {
      styledSpans.add(
        TextSpan(
          text: content.substring(0, boldLength),
          style: (span.style ?? const TextStyle()).copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
    if (boldLength < content.length) {
      styledSpans.add(
        TextSpan(text: content.substring(boldLength), style: span.style),
      );
    }
    position += content.length;
  }
  return SelectableText.rich(
    TextSpan(
      style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
      children: styledSpans,
    ),
  );
}

class _JsonNode extends StatefulWidget {
  const _JsonNode({
    super.key,
    required this.label,
    required this.value,
    required this.query,
    required this.branches,
    required this.path,
  });
  final String? label;
  final dynamic value;
  final String query;
  final Map<String, bool> branches;
  final String path;
  @override
  State<_JsonNode> createState() => _JsonNodeState();
}

class _JsonNodeState extends State<_JsonNode> {
  @override
  Widget build(BuildContext context) {
    final value = widget.value;
    final prefix = widget.label == null ? '' : '${widget.label}: ';
    if (value is! Map && value is! List) {
      return Padding(
        padding: const EdgeInsets.only(left: 32, top: 4, bottom: 4),
        child: _highlight(
          '$prefix${jsonEncode(value)}',
          widget.query,
          labelLength: prefix.length,
        ),
      );
    }
    final isMap = value is Map;
    final entries =
        isMap
            ? value.entries
                .map((entry) => MapEntry(entry.key.toString(), entry.value))
                .toList()
            : (value as List)
                .asMap()
                .entries
                .map((entry) => MapEntry('[${entry.key}]', entry.value))
                .toList();
    final open =
        (widget.branches[widget.path] ?? false) || widget.query.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
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
                      : () =>
                          setState(() => widget.branches[widget.path] = !open),
              icon: Icon(open ? Icons.arrow_drop_down : Icons.arrow_right),
            ),
            Expanded(
              child: _highlight(
                '$prefix${isMap ? '{}' : '[]'}  ${entries.length} items',
                widget.query,
                labelLength: prefix.length,
              ),
            ),
          ],
        ),
        if (open) ...[
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final entry in entries)
                  _JsonNode(
                    key: ValueKey(entry.key),
                    label: entry.key,
                    value: entry.value,
                    query: widget.query,
                    branches: widget.branches,
                    path:
                        '${widget.path}/${entry.key.replaceAll('~', '~0').replaceAll('/', '~1')}',
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
