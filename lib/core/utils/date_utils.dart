import '../constants/app_strings.dart';

class AppDateUtils {
  AppDateUtils._();

  static String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return AppStrings.goodMorning;
    if (hour < 17) return AppStrings.goodAfternoon;
    return AppStrings.goodEvening;
  }

  static String getWeekRangeLabel(DateTime weekStart) {
    final weekEnd = weekStart.add(const Duration(days: 6));
    if (weekStart.month == weekEnd.month) {
      return '${weekStart.day} - ${weekEnd.day} ${_monthName(weekStart.month)} ${weekStart.year}';
    }
    return '${weekStart.day} ${_shortMonth(weekStart.month)} - ${weekEnd.day} ${_shortMonth(weekEnd.month)} ${weekEnd.year}';
  }

  static String _monthName(int month) {
    const months = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month];
  }

  static String getMonthLabel(DateTime date) {
    return '${_monthName(date.month)} ${date.year}';
  }

  static String _shortMonth(int month) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month];
  }
}
