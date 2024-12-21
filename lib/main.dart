import 'package:flutter/material.dart';
import 'package:flutter_application_2/widgets/text_form_field.dart';


import 'widgets/home_screen.dart';
import 'widgets/text_field.dart';

//import 'package:flutter_application_2/db/db_helper.dart';


void main() async{

  //DbHelper helper = DbHelper();
// DbHelper.helper.getPath();


  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
      
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // home:  HomeScreen(),
      home:  const TextFormFieldWidget (),

    );
  }
}

