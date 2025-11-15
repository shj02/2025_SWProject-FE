import 'package:flutter/material.dart';

class ScheduleDay {
  ScheduleDay({
    required this.id,
    required this.title,
    required this.items,
  });

  final String id;
  final String title;
  final List<ScheduleEntry> items;
}

class ScheduleEntry {
  ScheduleEntry({
    required this.id,
    required this.time,
    required this.title,
    required this.location,
    this.editors = const [],
    this.memo = '',
  });

  final String id;
  final TimeOfDay time;
  final String title;
  final String location;
  final List<String> editors;
  final String memo;

  String get formattedTime => formatTime(time);

  ScheduleEntry copyWith({
    TimeOfDay? time,
    String? title,
    String? location,
    List<String>? editors,
    String? memo,
  }) {
    return ScheduleEntry(
      id: id,
      time: time ?? this.time,
      title: title ?? this.title,
      location: location ?? this.location,
      editors: editors ?? this.editors,
      memo: memo ?? this.memo,
    );
  }

  static String formatTime(TimeOfDay time) {
    final int hour = time.hour;
    final int minute = time.minute;
    final String hh = hour.toString().padLeft(2, '0');
    final String mm = minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }
}

