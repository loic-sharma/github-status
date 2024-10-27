import 'package:timeago/timeago.dart' as timeago;

void registerTimeago() {
  timeago.setLocaleMessages('en', _TimeagoEnMessages());
}

// Removes "about" prefixes from timeago messages.
class _TimeagoEnMessages extends timeago.EnMessages {
  @override
  String aboutAMinute(int minutes) => '1 minute';
  @override
  String aboutAnHour(int minutes) => '1 hour';
  @override
  String aDay(int hours) => '1 day';
  @override
  String aboutAMonth(int days) => '1 month';
  @override
  String aboutAYear(int year) => '1 year';
}
