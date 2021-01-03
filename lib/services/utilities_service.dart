import 'package:intl/intl.dart';

class UtilitiesService {
  // Abitrary id for a day - set at 12pm noon - this can be set to whatever works.
  static int getDayId(DateTime date) {
    DateTime timeAtNoon = DateTime(date.year, date.month, date.day, 12);

    return timeAtNoon.millisecondsSinceEpoch;
  }

  static int getFirstDay(DateTime date) {
    return date.day - date.weekday;
  }

  static DateTime getFirstDayOfWeek(DateTime date) {
    int firstDay = getFirstDay(date);
    int daysAfterFirstDay = date.day - firstDay;
    DateTime firstDayOfWeek = date.subtract(Duration(days: daysAfterFirstDay));
    return firstDayOfWeek;
  }

  static DateTime getLastDayOfWeek(DateTime date) {
    int lastDay = getFirstDay(date) + 6;
    int daysToLastDay = lastDay - date.day;
    DateTime lastDayOfWeek = date.add(Duration(days: daysToLastDay));
    return lastDayOfWeek;
  }

  static int getStartOfWeekDayId(DateTime date) {
    DateTime firstDayOfWeek = getFirstDayOfWeek(date);

    // return the first hour to ensure the time starts before the set id of noon
    return DateTime(firstDayOfWeek.year, firstDayOfWeek.month, firstDayOfWeek.day, 1)
        .millisecondsSinceEpoch;
  }

  static int getEndOfWeekDayId(DateTime date) {
    DateTime firstDayOfWeek = getLastDayOfWeek(date);

    // return the 23rd hour to ensure the time starts after the set day id of noon
    return DateTime(firstDayOfWeek.year, firstDayOfWeek.month, firstDayOfWeek.day, 23)
        .millisecondsSinceEpoch;
  }

  // Calculates the first and last day of the week and returns a user friendly string of the week
  static String getUserFriendlyWeekId(DateTime date) {
    DateTime firstDayOfWeek = getFirstDayOfWeek(date);
    DateTime lastDayOfWeek = getLastDayOfWeek(date);

    DateFormat formatDate = DateFormat.yMMMd();
    String firstDayString = formatDate.format(firstDayOfWeek);
    String lastDayString = formatDate.format(lastDayOfWeek);

    return '$firstDayString - $lastDayString';
  }

  static int getDayFromEpoch(double epoch) {
    DateTime date = DateTime.fromMillisecondsSinceEpoch(epoch.toInt());

    return date.day;
  }
}
