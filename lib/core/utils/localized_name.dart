import 'package:equatable/equatable.dart';

class LocalizedName extends Equatable {
  const LocalizedName({required this.ar, required this.en});
  final String ar, en;
  String of(String language) => language == 'ar' ? ar : en;

  static LocalizedName? fromJson(Object? json) => json is Map
      ? LocalizedName(ar: '${json['ar'] ?? ''}', en: '${json['en'] ?? ''}')
      : null;

  @override
  List<Object?> get props => [ar, en];
}
