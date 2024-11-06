import 'package:flutter/material.dart';

class Screens extends StatefulWidget {
   const Screens({super.key});
  

  @override
  State<Screens> createState() => _ScreensState();
}

class _ScreensState extends State<Screens> {
  int index=0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
          onTap: (value) {
            setState(() {
              index=value;
            });
          },
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(
                icon: Icon(Icons.shopping_basket), label: "shopping_basket"),
            BottomNavigationBarItem(
                icon: Icon(Icons.notifications), label: "notifications"),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: "search"),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "person"),
          ]),
          body: setPage(),
    );
  }
  Widget setPage(){
    switch(index){


case 0 : return Container(color: Colors.amber,);
case 1 : return Container(color: Color.fromARGB(255, 6, 146, 125),);
case 2 : return Container(color: const Color.fromARGB(255, 83, 64, 7),);
case 3 : return Container(color: Color.fromARGB(255, 227, 42, 5),);
default : return Container(color: Color.fromARGB(255, 220, 8, 167),);









    }
  }
}
