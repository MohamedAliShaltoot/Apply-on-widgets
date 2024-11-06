import 'package:flutter/material.dart';
import 'package:flutter_application_2/bottomnavigationbar.dart';
import 'package:flutter_application_2/home_screen2.dart';
import 'package:flutter_application_2/pageview.dart';
import 'package:flutter_application_2/tabbar.dart';
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
      home: PagesViewScreen(),

    );
  }
}

