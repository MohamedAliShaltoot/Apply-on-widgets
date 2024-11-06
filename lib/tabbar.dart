import 'package:flutter/material.dart';

class TabBarScreen extends StatelessWidget {
  const TabBarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 95, 118, 153),
          centerTitle: true,
          title: const Text(
            "Flutter App",
            style: TextStyle(
                fontStyle: FontStyle.italic,
                decoration: TextDecoration.underline),
          ),
          bottom: const TabBar(tabs: [

            Tab(icon: Icon(Icons.group),text: "group",),
             Tab(icon: Icon(Icons.phone),text: "phone",),
              Tab(icon: Icon(Icons.home),text: "home",),

          ]),
        ),
        body: TabBarView(children: [
          Container(color: Colors.amber,),
          Container(color: const Color.fromARGB(255, 35, 31, 18),),
          Container(color: Color.fromARGB(255, 4, 207, 96),),
          
        ],),
      
      ),
    );
  }
}
