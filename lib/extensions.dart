import 'package:cloud_firestore/cloud_firestore.dart';

extension TimeStampExt on Timestamp{
  DateTime get toDateTime=>DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch);
}

extension DTExt on DateTime {
  String get formatDDMMYY=>'$day-$month-$year';
}