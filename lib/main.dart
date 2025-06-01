import 'package:flutter/material.dart';
import 'package:flutter_application_2/screens/home_2.dart';
import 'package:flutter_application_2/screens/test_home.dart';

import 'widgets/home_screen.dart';

//import 'package:flutter_application_2/db/db_helper.dart';

void main() async {
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
        // ignore: prefer_const_constructors
        home: Home()

        //const TextFormFieldWidget (),

        );
  }
}
