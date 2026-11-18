import 'package:cloud_firestore/cloud_firestore.dart';

DateTime readDate(Object? value) => (value as Timestamp).toDate();
DateTime? readOptionalDate(Object? value) =>
    value == null ? null : readDate(value);
