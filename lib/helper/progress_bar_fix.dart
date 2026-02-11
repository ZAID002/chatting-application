import 'package:flutter/material.dart';
class Fix{
  static void showprogress(BuildContext context){
    showDialog(context: context, builder: (_)=> Center(child: CircularProgressIndicator()));
  }
}