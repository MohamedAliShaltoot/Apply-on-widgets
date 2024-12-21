// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_application_2/widgets/alert_dialog.dart';
//import 'package:flutter_application_2/widgets/snackbar.dart';

class TextFieldWidget extends StatefulWidget {
  const TextFieldWidget({super.key});

  @override
  State<TextFieldWidget> createState() => _TextFieldWidgetState();
}

class _TextFieldWidgetState extends State<TextFieldWidget> {
  TextEditingController nameController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("TextField Widget"),
      ),
      body: Column(
        children: [
          TextField(
            controller: nameController,
            decoration: InputDecoration(
                border: OutlineInputBorder(), hintText: "Enter Your Name"),
          ),
          ElevatedButton(onPressed: () {
            showAlertDialog(context, nameController.text);
           // showSnackBar(context, nameController.text);
          }, child: Text("Submit")),
        ],
      ),
    );
  }
}
