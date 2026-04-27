import 'package:intl/intl.dart';

extension DateTimeExtensions on DateTime {
  DateTime get dateOnly => DateTime(year, month, day);

  bool isSameDay(DateTime other) =>
      year == other.year && month == other.month && day == other.day;

  bool isSameMonth(DateTime other) =>
      year == other.year && month == other.month;

  bool get isToday => isSameDay(DateTime.now());
  bool get isTomorrow =>
      isSameDay(DateTime.now().add(const Duration(days: 1)));
  bool get isYesterday =>
      isSameDay(DateTime.now().subtract(const Duration(days: 1)));

  bool get isPast => isBefore(DateTime.now().dateOnly);
  bool get isFuture => isAfter(DateTime.now().dateOnly);

  String get formattedDate => DateFormat('MMM d, yyyy').format(this);
  String get formattedShortDate => DateFormat('MMM d').format(this);
  String get formattedDayMonth => DateFormat('d MMM').format(this);
  String get formattedTime => DateFormat('h:mm a').format(this);
  String get formattedWeekday => DateFormat('EEEE').format(this);
  String get formattedShortWeekday => DateFormat('EEE').format(this);
  String get formattedFullDate => DateFormat('EEEE, MMMM d').format(this);
  String get formattedMonthYear => DateFormat('MMMM yyyy').format(this);

  DateTime get startOfWeek {
    final diff = weekday - DateTime.monday;
    return subtract(Duration(days: diff)).dateOnly;
  }

  DateTime get endOfWeek {
    final diff = DateTime.sunday - weekday;
    return add(Duration(days: diff)).dateOnly;
  }

  DateTime get startOfMonth => DateTime(year, month, 1);
  DateTime get endOfMonth => DateTime(year, month + 1, 0);

  List<DateTime> get daysInWeek {
    final start = startOfWeek;
    return List.generate(7, (i) => start.add(Duration(days: i)));
  }

  String get relativeLabel {
    if (isToday) return 'Today';
    if (isTomorrow) return 'Tomorrow';
    if (isYesterday) return 'Yesterday';
    return formattedDate;
  }
}
