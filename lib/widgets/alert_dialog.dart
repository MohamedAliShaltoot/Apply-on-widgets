import 'package:flutter/material.dart';

 showAlertDialog(BuildContext context, String message) {
 showDialog(context: context, builder:( builder){
  return  AlertDialog(
    title: const Text('Information',style: TextStyle(color: Color.fromARGB(255, 12, 12, 12),fontStyle: FontStyle.italic,),),
    content: Text("your name is $message"),
     actions: [
          ElevatedButton(

            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all<Color>(
                Colors.orange)
            ),
            onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Confirm',
          style: TextStyle(color: Colors.black,
            fontWeight: FontWeight.bold)),
            ),]
  );
 });
 
 
 
 
 
 
 
 
 
 
 



}