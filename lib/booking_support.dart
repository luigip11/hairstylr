import 'package:cloud_firestore/cloud_firestore.dart';

class SalonService {
  const SalonService({
    required this.id,
    required this.name,
    required this.description,
    this.durationMinutes,
    this.price,
    required this.active,
  });

  final String id;
  final String name;
  final String description;
  final int? durationMinutes;
  final num? price;
  final bool active;

  factory SalonService.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return SalonService(
      id: doc.id,
      name: (data['name'] as String?) ?? 'Servizio',
      description: (data['description'] as String?) ?? '',
      durationMinutes: (data['durationMinutes'] as num?)?.toInt(),
      price: data['price'] as num?,
      active: (data['active'] as bool?) ?? true,
    );
  }
}

class AvailabilitySchedule {
  const AvailabilitySchedule({
    required this.timezone,
    required this.weeklySchedule,
  });

  final String timezone;
  final Map<String, List<String>> weeklySchedule;

  factory AvailabilitySchedule.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    final rawWeeklySchedule =
        (data['weeklySchedule'] as Map<String, dynamic>?) ??
        <String, dynamic>{};

    return AvailabilitySchedule(
      timezone: (data['timezone'] as String?) ?? 'Europe/Rome',
      weeklySchedule: rawWeeklySchedule.map((key, value) {
        final values = value is List
            ? value.map((item) => item.toString()).toList(growable: false)
            : <String>[];
        return MapEntry(key, values);
      }),
    );
  }

  List<String> windowsForDate(DateTime date) {
    return weeklySchedule[weekdayKey(date.weekday)] ?? const <String>[];
  }
}

class TimeSlot {
  const TimeSlot({
    required this.start,
    required this.end,
  });

  final DateTime start;
  final DateTime end;
}

List<TimeSlot> buildSlotsForDate(
  DateTime date,
  List<String> windows,
) {
  final slots = <TimeSlot>[];

  for (final window in windows) {
    final parts = window.split('-');
    if (parts.length != 2) {
      continue;
    }

    final start = combineDateAndTime(date, parts[0]);
    final end = combineDateAndTime(date, parts[1]);
    if (start == null || end == null || !end.isAfter(start)) {
      continue;
    }

    slots.add(TimeSlot(start: start, end: end));
  }

  return slots;
}

DateTime? combineDateAndTime(DateTime date, String value) {
  final parts = value.split(':');
  if (parts.length != 2) {
    return null;
  }

  final hour = int.tryParse(parts[0]);
  final minute = int.tryParse(parts[1]);
  if (hour == null || minute == null) {
    return null;
  }

  return DateTime(date.year, date.month, date.day, hour, minute);
}

DateTime dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);

bool isSameDate(DateTime left, DateTime right) =>
    left.year == right.year &&
    left.month == right.month &&
    left.day == right.day;

String weekdayKey(int weekday) => switch (weekday) {
  DateTime.monday => 'monday',
  DateTime.tuesday => 'tuesday',
  DateTime.wednesday => 'wednesday',
  DateTime.thursday => 'thursday',
  DateTime.friday => 'friday',
  DateTime.saturday => 'saturday',
  DateTime.sunday => 'sunday',
  _ => 'monday',
};

String weekdayShort(DateTime date) => switch (date.weekday) {
  DateTime.monday => 'Lun',
  DateTime.tuesday => 'Mar',
  DateTime.wednesday => 'Mer',
  DateTime.thursday => 'Gio',
  DateTime.friday => 'Ven',
  DateTime.saturday => 'Sab',
  DateTime.sunday => 'Dom',
  _ => '',
};

String monthShort(DateTime date) => switch (date.month) {
  1 => 'Gen',
  2 => 'Feb',
  3 => 'Mar',
  4 => 'Apr',
  5 => 'Mag',
  6 => 'Giu',
  7 => 'Lug',
  8 => 'Ago',
  9 => 'Set',
  10 => 'Ott',
  11 => 'Nov',
  12 => 'Dic',
  _ => '',
};

String monthLong(DateTime date) => switch (date.month) {
  1 => 'Gennaio',
  2 => 'Febbraio',
  3 => 'Marzo',
  4 => 'Aprile',
  5 => 'Maggio',
  6 => 'Giugno',
  7 => 'Luglio',
  8 => 'Agosto',
  9 => 'Settembre',
  10 => 'Ottobre',
  11 => 'Novembre',
  12 => 'Dicembre',
  _ => '',
};

String formatDate(DateTime date) =>
    '${weekdayShort(date)} ${date.day} ${monthShort(date)}';

String formatTime(DateTime date) =>
    '${twoDigits(date.hour)}:${twoDigits(date.minute)}';

String formatTimeRange(DateTime start, DateTime end) =>
    '${formatTime(start)} - ${formatTime(end)}';

String dateKey(DateTime date) =>
    '${date.year}${twoDigits(date.month)}${twoDigits(date.day)}';

String twoDigits(int value) => value.toString().padLeft(2, '0');
