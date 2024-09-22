import 'package:flutter/material.dart';

extension ContextExtension on BuildContext {
  void showSnackBar(String message,{ String? actionLabet, VoidCallback? onCtick}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        action: SnackBarAction(
            label: actionLabet ?? '', textColor: Colors.blue,
             onPressed: onCtick ?? (){}),
            
      ),
    );
  }
}
