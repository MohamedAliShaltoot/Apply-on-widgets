import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  bool isChecked = true;
  @override
  void initState() {
    super.initState();
    setState(() {
      SharedPreferences.getInstance().then((value) => isChecked=value.getBool('Checked') ?? false);
         //print('gghgh');
    // SharedPreferences.getInstance().then((prfes) {
    //   isChecked=prfes.getBool('Checked') ?? false ;
    // });
    });
 
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: 
      Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Visibility(
                  visible: isChecked,
                  maintainAnimation: true,
                  maintainState: true,
                  maintainSize: true,
                  child: Image.asset(
                    'images/me.jpg',
                    width: MediaQuery.of(context).size.width,
                    height: 110,
                  ),
                ),
                const SizedBox(
              height: 20,
            ),
            CheckboxListTile(
                title: const Text(
                  "Show/Hide",
                  style: TextStyle(fontSize: 20, color: Colors.black),
                ),
                value: isChecked,
                onChanged: (value) {
                  setState(() {
                    isChecked = value!;
                  });
                }),
                ElevatedButton(onPressed: () async{
// setState(() {
  
// });
                 SharedPreferences prfes= await SharedPreferences.getInstance();
                 prfes.setBool("Checked", isChecked);
                }, child: const Text("save changes")),
        ],
      ),
             
           
      
      
      ),
    );
  }
}