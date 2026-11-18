import 'dart:convert';

import 'package:flutter/services.dart';

class EgyptLocation {
  const EgyptLocation({
    required this.id,
    required this.arabicName,
    required this.englishName,
    this.parentId,
  });
  final String id;
  final String arabicName;
  final String englishName;
  final String? parentId;

  String name(String language) => language == 'ar' ? arabicName : englishName;

  factory EgyptLocation.fromMap(Map<String, dynamic> map) {
    final name = map['name'] as Map<String, dynamic>;
    final parent = map['parent'] as Map<String, dynamic>?;
    return EgyptLocation(
      id: map['id'] as String,
      arabicName: name['local'] as String,
      englishName: name['en'] as String,
      parentId: parent?['id'] as String?,
    );
  }
}

/// Offline snapshot, not an official live administrative registry.
/// Source, pinned revision and CC-BY-4.0 attribution: assets/data/egypt/README.md.
class EgyptLocations {
  EgyptLocations({
    required List<EgyptLocation> governorates,
    required List<EgyptLocation> districts,
  }) : governorates = List.unmodifiable(governorates),
       districts = List.unmodifiable(districts);
  final List<EgyptLocation> governorates;
  final List<EgyptLocation> districts;

  List<EgyptLocation> districtsOf(String governorateId) => List.unmodifiable(
    districts.where((district) => district.parentId == governorateId),
  );

  static Future<EgyptLocations>? _cached;
  static Future<EgyptLocations> load() => _cached ??= _load();

  static Future<EgyptLocations> _load() async {
    try {
      final files = await Future.wait([
        rootBundle.loadString('assets/data/egypt/governorates.json'),
        rootBundle.loadString('assets/data/egypt/districts.json'),
      ]);
      List<EgyptLocation> parse(String text) =>
          (jsonDecode(text) as List<dynamic>)
              .map((row) => EgyptLocation.fromMap(row as Map<String, dynamic>))
              .toList();
      return EgyptLocations(
        governorates: parse(files[0]),
        districts: parse(files[1]),
      );
    } catch (_) {
      _cached = null;
      rethrow;
    }
  }
}

/// Normalize common Arabic spelling variants for forgiving local search.
String normalizeLocationSearch(String value) => value
    .trim()
    .toLowerCase()
    .replaceAll(RegExp('[أإآ]'), 'ا')
    .replaceAll('ى', 'ي')
    .replaceAll('ة', 'ه')
    .replaceAll(RegExp(r'[\u064B-\u065F\u0670\u0640]'), '');
