import 'package:flutter/material.dart';

class PagesViewScreen extends StatelessWidget {
   PagesViewScreen({super.key});
   int pageIndex=0;
   final PageController _pagecontroller = PageController(initialPage: 0);
List<Container> containers=[
  
  Container(color: Colors.amber,),
    Container(color: const Color.fromARGB(255, 50, 198, 4),),
      Container(color: const Color.fromARGB(255, 243, 67, 3),),
        Container(color: const Color.fromARGB(255, 205, 10, 101),),
          Container(color: const Color.fromARGB(255, 78, 3, 164),),

];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(onPageChanged: (value){
pageIndex=value;
      },scrollDirection: Axis.horizontal,controller: _pagecontroller,itemBuilder: (context,index){
       return containers[index];
      },itemCount: containers.length,),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          FloatingActionButton(onPressed: (){
            if(pageIndex==0){
              _pagecontroller.jumpToPage(containers.length-1);
            } else{
_pagecontroller.jumpToPage(--pageIndex);
            }

          },child: const Icon(Icons.arrow_back),),
          FloatingActionButton(onPressed: (){

            if(pageIndex==4){
              _pagecontroller.jumpToPage(0);
            } else{
_pagecontroller.jumpToPage(++pageIndex);
            }
          },child: const Icon(Icons.arrow_forward),),
        ],
      ),
    );
  }
}