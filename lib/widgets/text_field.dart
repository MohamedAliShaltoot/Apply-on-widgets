// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class TextFieldWidget extends StatefulWidget {
  const TextFieldWidget({super.key});

  @override
  State<TextFieldWidget> createState() => _TextFieldWidgetState();
}

class _TextFieldWidgetState extends State<TextFieldWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("TextField Widget"),
      ),
      body: Center(child: TextField(
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          hintText: "Enter Your Name"
        ),
      )),
    );
  }
}
