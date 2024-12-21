
import 'package:flutter/material.dart';

void showSnackBar(
  BuildContext context,
  String message,
) {
  var snackBar = SnackBar(content: Text("your name is $message"),
  action: SnackBarAction(label: 'Ok',onPressed: (){
   
  }),);
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
