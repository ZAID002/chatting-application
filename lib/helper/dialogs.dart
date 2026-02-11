import 'package:flutter/material.dart';
class Dialogs {
  static void showsnackbar(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Center(child: Text(msg)),
        backgroundColor: Colors.blue.withValues(alpha: 0.8),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

}
