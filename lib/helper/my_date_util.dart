import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

///for getting formatted time from millisecondsSinceEpoch String
class MyDateUtil {
  static String getFormattedTime({
    required BuildContext context,
    required String time,
  }) {
    final date = DateTime.fromMillisecondsSinceEpoch(int.parse(time));
    return TimeOfDay.fromDateTime(date).format(context);
  }
///get message formatted time for bottomsheet in chat screen used in message_card.dart
  static String getMessageTime({
    required BuildContext context,
    required String time,
  }) {
    final DateTime sent =
    DateTime.fromMillisecondsSinceEpoch(int.parse(time));
    final DateTime now = DateTime.now();

    final String formattedTime =
    TimeOfDay.fromDateTime(sent).format(context);

    // TODAY
    if (now.day == sent.day &&
        now.month == sent.month &&
        now.year == sent.year) {
      return formattedTime;
    }

    // YESTERDAY
    final DateTime yesterday = now.subtract(const Duration(days: 1));
    if (yesterday.day == sent.day &&
        yesterday.month == sent.month &&
        yesterday.year == sent.year) {
      return '$formattedTime Yesterday';
    }

    // SAME YEAR
    if (now.year == sent.year) {
      return '$formattedTime ${sent.day} ${_getMonth(sent)}';
    }

    // DIFFERENT YEAR
    return '$formattedTime ${sent.day} ${_getMonth(sent)} ${sent.year}';
  }

  ///get last message time (used in chat user card)
  static String getLastMesssageTime({
    required BuildContext context,
    required String time,bool showYear = false,
  }) {
    final DateTime sent = DateTime.fromMillisecondsSinceEpoch(int.parse(time));
    final DateTime now = DateTime.now();
    if (now.day == sent.day &&
        now.month == sent.month &&
        now.year == sent.year) {
      return TimeOfDay.fromDateTime(sent).format(context);
    }
    return showYear ?'${sent.day} ${_getMonth(sent)}${sent.year}':'${sent.day} ${_getMonth(sent)}';}



  ///get last active formated time of user in chat screen
static  String getLastActiveTime({
    required BuildContext context,
    required String lastActive,
  }) {
    final int i =int.tryParse(lastActive)?? -1;
    //if time is not available
    if (i == -1) {
      return 'Last seen not available';
    }
    final DateTime time = DateTime.fromMillisecondsSinceEpoch(i);
    final DateTime now = DateTime.now();
    String formatedTime =TimeOfDay.fromDateTime(time).format(context);
    if(now.day == time.day && now.month == time.month && now.year == time){
      return 'last seen today at $formatedTime';
    }
    if((now.difference(time).inHours/24).round()==1){
      return 'last seen yesterday at $formatedTime';

    }
    String? month = _getMonth(time);
    return 'last seen on ${time.day} $month on $formatedTime ';
  }
  ///get month name from month no or index
  static String? _getMonth(DateTime date) {
    switch (date.month) {
      case 1:
        return 'Jan';
      case 2:
        return 'Feb';
      case 3:
        return 'Mar';
      case 4:
        return 'Apr';
      case 5:
        return 'May';
      case 6:
        return 'Jun';
      case 7:
        return 'Jul';
      case 8:
        return 'Aug';
      case 9:
        return 'Sept';
      case 10:
        return 'Oct';
      case 11:
        return 'Nov';
      case 12:
        return 'Dec';
    }
  }

}
