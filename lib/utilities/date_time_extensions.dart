extension DateTimeExtensions on DateTime {

  static DateTime? safeParse(String? date) {
    if (date == null) {
      return null;
    }
    return DateTime.parse(date);
  }

}